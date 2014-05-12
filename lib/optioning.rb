require "optioning/version"
require "deprecation"

class Optioning
  # Receives a varargs to extract the values (anything before a last parameter
  # `Hash`) and the options (last parameter instance_of `Hash`)
  #
  # These values can be retrieved using the methods {#values}, {#raw} and {#on}.
  #
  # @example a standard usage
  #   @options = Optioning.new :path, :commit, to_hash: ->(value) { value.upcase }
  #   @options.deprecate :to_hash, :to, Date.new(2015, 05, 01)
  #
  #   @ivars = @options.values
  #   # => [:path, :commit]
  #
  #   @to = @options.on :to
  #   # => #<Proc:0x8d99c54@(irb):42 (lambda)>
  def initialize(args)
    @args = args
    @values = @args.dup
    @options = @values.pop if @args.last.is_a? Hash
  end

  # Return the value for a specific option
  #
  # @example
  #   @option = Optioning.new [:path, :commit, stored_value: 42]
  #   @option.on :stored_value
  #   # => 42
  #
  # @param option [Symbol] (or Object used as an index) name of option to retrieve
  # @return value for option passed as parameter
  def on(option)
    replace_deprecations
    @options[option]
  end

  # Creates a deprecation for an option, stores info about it's replacement
  # and time or version to its removal.
  #
  # @example
  #   @option = Optioning.new :path, :commit, to_hash: ->(value) { value.upcase }
  #   @option.deprecate :to_hash, :to, Date.new(2015, 05, 01)
  #
  # @param option [Symbol] option to be deprecated
  # @param replacement [Symbol] replacement option
  # @param version_or_year version when the deprecation will be removed, if
  #   month is filled, this param will be treated as the year of replacement
  # @param month [Integer] month when the deprecated option will be removed
  # @return [Optioning] the current instance of optioning
  def deprecate(option, replacement, version_or_year = nil, month = nil)
    deprecations << Deprecation.new(option, replacement, version_or_year, month)
    recognize(replacement)
    self
  end

  # Provides a way to inform which options can be used and which will be ignored
  # by an instance of {Optioning}
  #
  # @example
  #   @options = Optioning.new :path, :commit, to_hash: ->(value) { value.upcase }
  #   @options.deprecate :to_hash, :to, Date.new(2015, 05, 01)
  #
  # @param options [Array<Symbol>] all recognized options for the current {Optioning}
  # @return [Optioning] the current {Optioning} instance
  def recognize(*options)
    @recognized ||= []
    @recognized += options
    self
  end

  # Issues all deprecation messages to the $stderr
  #
  # @param called_from [Array] expected to be the result of calling `caller`
  # @return [Optioning] current {Optioning} instance
  def deprecation_warn(called_from = nil)
    set_caller_on_deprecations(called_from)
    deprecations.select { |deprecation|
      deprecated_but_used.include? deprecation.option
    }.each { |deprecation| $stderr.write deprecation.warn }
    self
  end

  # Issues all unrecognized messages and the recognized_options message to the $stderr
  #
  # @param called_from [Array<String>] the result of calling {Object#caller}
  # @return [Optioning] the current {Optioning} instance
  def unrecognized_warn(called_from = nil)
    unrecognized_options.each do |unrecognized|
      $stderr.write "NOTE: unrecognized option `:#{unrecognized}` used.\n"
    end
    recognized_options_warn called_from
    self
  end

  # Issues the deprecation warnings and the unrecognized warnings.
  # Let the current {Optioning} in a `ready to use` state.
  #
  # @param called_from [Array<String>] the result of calling {Object#caller}
  # @return [Optioning] the current {Optioning} instance
  def process(called_from = nil)
    deprecation_warn called_from
    unrecognized_warn called_from
    self
  end

  # Return all values passed as varargs to the constructor.
  #
  # @return [Array] all values passed to the constructor
  def raw
    @args
  end

  # Return all the values passed before the last one (if this one is a `Hash`
  # instance).
  #
  # @return [Array] arguments that are not part of the options `Hash`
  def values
    @values
  end

  private
  # Memoization for the `deprecations` created by invocations of {#deprecate}
  #
  # @return [Array<Deprecation>] all {Deprecation}s for these {Optioning} instance
  def deprecations
    @deprecations ||= []
  end

  # Memoization for the `recognized` options created by {#recognize}
  #
  # @return [Array<Symbol>] all options recognized by this {Optioning}
  def recognized
    @recognized ||= []
  end

  def options
    @options ||= []
  end

  # Cleanup the options trashing up the deprecated options in favor the
  # replacements.
  #
  # @return [Hash] @options already filtered
  def replace_deprecations
    deprecations.each do |deprecation|
      options[deprecation.replacement] = options.delete deprecation.option
    end
    options
  end

  # All unrecognized options used as parameter to an {Optioning}
  #
  # @return [Array<Symbol>] unrecognized options
  def unrecognized_options
    values = raw.dup
    return [] unless values.last.is_a? Hash
    options = values.pop
    options.keys - (recognized + deprecations.map { |d| d.option.to_sym })
  end

  # Issues a message containing all the recognized options for an {Optioning}
  #
  # @param called_from [Array<String>] the result of calling {Kernel#caller}
  def recognized_options_warn(called_from = nil)
    recognized = @recognized.map { |option| "`:#{option}`" }
    $stderr.write "You should use only the following: #{recognized.join(", ")}"
    $stderr.write "\nCalled from #{called_from.first}." if called_from.respond_to? :first
  end

  # Configure the caller in all the deprecations for this instance
  #
  # @return [Array<Deprecations>]
  def set_caller_on_deprecations(called_from)
    return unless called_from.respond_to? :first
    deprecations.each { |deprecation| deprecation.caller = called_from.first }
  end

  # All deprecated options that were passed to the constructor for this instance
  # of {Optioning}
  #
  # @return [Array<Symbol>] deprecated options used in the construction of a {Optioning}
  def deprecated_but_used
    deprecations.map(&:option).select { |option| options.include? option  }
  end
end

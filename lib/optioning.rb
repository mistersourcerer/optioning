require "optioning/version"
require "deprecation"

class Optioning
  # Receives a varargs to extract the values (anything before a last parameter
  # `Hash`) and the options (last parameter instance_of `Hash`)
  #
  # These values can be retrieved using the methods {#values}, {#raw} and {#on}.
  #
  # @example a standard usage
  #
  #   @options = Optioning.new :path, :commit, to_hash: ->(value) { value.upcase }
  #   @options.deprecate :to_hash, :to, Date.new(2015, 05, 01)
  #
  #   @ivars = @options.values
  #   # => [:path, :commit]
  #
  #   @to = @options.on :to
  #   # => #<Proc:0x8d99c54@(irb):42 (lambda)>
  def initialize(*args)
    @args = args
    @values = @args.dup
    @options = @values.pop if @args.last.is_a? Hash
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

  # Return the value for a specific option
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
  # @param option [Symbol] option to be deprecated
  # @param replacement [Symbol] replacement option
  # @param version_or_year version when the deprecation will be removed, if
  # month is filled, this param will be treated as the year of replacement
  # @param month [Integer] month when the deprecated option will be removed
  # @return [Optioning] the current instance of optioning
  def deprecate(option, replacement, version_or_year = nil, month = nil)
    deprecations << Deprecation.new(option, replacement, version_or_year, month)
    recognize(replacement)
    self
  end

  # 
  def deprecation_warn(called_from = nil)
    set_caller_on_deprecations(called_from)
    deprecations.select { |deprecation|
      deprecated_but_used.include? deprecation.option
    }.each { |deprecation| $stderr.write deprecation.warn }
    self
  end

  def deprecated_but_used
    deprecations.map(&:option).select { |option| @options.include? option  }
  end

  def recognize(*options)
    @recognized ||= []
    @recognized += options
    self
  end

  def unrecognized_warn(called_from = nil)
    values = raw.dup
    if values.last.is_a? Hash
      options = values.pop
      unrecognized = options.keys - (recognized + deprecations.map { |d| d.option.to_sym })
      unrecognized.each do |unrec|
        $stderr.write "NOTE: unrecognized option `:#{unrec}` used.\n"
      end
      recognized = @recognized.map { |option| "`:#{option}`" }
      $stderr.write "You should use only the following: #{recognized.join(", ")}"
      $stderr.write "\nCalled from #{called_from.first}." if called_from.respond_to? :first
    end
    self
  end

  def process(called_from = nil)
    deprecation_warn called_from
    unrecognized_warn called_from
    self
  end

  private
  # Memoization for the `deprecations` created by invocations of {#deprecate}
  #
  # @return [Array] all {Deprecation}s for these {Optioning} instance
  def deprecations
    @deprecations ||= []
  end

  def recognized
    @recognized ||= []
  end

  # Cleanup the options trashing up the deprecated options in favor the
  # replacements.
  #
  # @return [Hash] @options already filtered
  def replace_deprecations
    deprecations.each do |deprecation|
      @options[deprecation.replacement] = @options.delete deprecation.option
    end
    @options
  end

  def set_caller_on_deprecations(called_from)
    return unless called_from && called_from.respond_to?(:first)
    deprecations.each { |deprecation| deprecation.caller = called_from.first }
  end
end

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

  def recognize
    
    self
  end

  def unrecognized_warn
    
    self
  end

  def deprecate(option, replacement, version_or_year = nil, month = nil)
    deprecations << Deprecation.new(option, replacement, version_or_year, month)
    self
  end

  def deprecation_warn
    deprecations.each { |deprecation| $stderr.write deprecation.warn }
    self
  end

  def process
    
    self
  end

  private
  # Memoization for the `deprecations` created by invocations of {#deprecate}
  #
  # @return [Array] all {Deprecation}s for these {Optioning} instance
  def deprecations
    @deprecations ||= []
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
end

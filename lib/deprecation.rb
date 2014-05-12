# Represent a deprecated option.
# Util to store deprecated options for future reference.
class Deprecation
  attr_reader :option, :replacement, :date, :version
  attr_writer :caller

  # Creates a representation of a {Deprecation}
  #
  # @example using a version as a deadline to deprecate
  #   deprecation = Deprecation.new :to_hash, :to, "v2.0.0"
  #   deprecation.warn
  #   # => NOTE: option `:to_hash` is deprecated; use `:to` instead. It will be
  #   #    removed on or after version v2.0.0.
  #
  # @example using a date (YYYY/MM) as a deadline to deprecate
  #   deprecation = Deprecation.new :to_hash, :to, 2015, 05
  #   deprecation.warn
  #   # => NOTE: option `:to_hash` is deprecated; use `:to` instead. It will be
  #   #    removed on or after 2015-05-01.
  #
  # @example using the caller information to compose the warn message
  #   deprecation = Deprecation.new :to_hash, :to, "v2.0.0"
  #   deprecation.warn
  #   deprecation.caller = caller
  #   # => NOTE: option `:to_hash` is deprecated; use `:to` instead. It will be
  #   #    removed on or after version v2.0.0.
  #   #    Called from examples/client_maroto.rb:5:in `<class:Client>'.
  def initialize(option, replacement, version_or_year = nil, month = nil)
    @option = option
    @replacement = replacement
    @date, @version = extract_date_and_version version_or_year, month
  end

  # Composes the deprecation message accordingly to date or version of
  # deprecation. Also verifies (and show) the caller information.
  #
  # @return [String]
  def warn
    message = [ "NOTE: option `:#{@option}` is deprecated; use ",
                "`:#{@replacement}` instead. ",
                "It will be removed #{when_deprecation_occurs}."]
    message << "\nCalled from #{@caller}." if @caller
    message.join << "\n"
  end

  private
  # Decides if the parameters related to when a deprecation will occur are date
  # or version based.
  #
  # @return [Array<Date, String>] the [Date] or version (string) for a deprecation
  def extract_date_and_version(version_or_year, month)
    date, version = nil, nil
    if month.nil?
      version = version_or_year
    else
      date = Date.new version_or_year, month, 1
    end
    [date, version]
  end

  # Returns a string ready to be used in a message, indicating when a
  # deprecation will occur (based on date or version).
  #
  # @return [String]
  def when_deprecation_occurs
    if @date || @version
      after = "on or after "
      after += @date ? @date.strftime("%Y-%m-%d") : "version #{@version}"
    else
      "in a future version"
    end
  end
end

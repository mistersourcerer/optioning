# Represent a deprecated option.
# Util to store deprecated options for future reference.
class Deprecation
  attr_reader :option, :replacement, :date, :version
  attr_writer :caller

  def initialize(option, replacement, version_or_year = nil, month = nil)
    @option = option
    @replacement = replacement
    @date, @version = extract_date_and_version version_or_year, month
  end

  def warn
    message = [ "NOTE: option `:#{@option}` is deprecated; use ",
                "`:#{@replacement}` instead. ",
                "It will be removed #{when_deprecation_occurs}."]
    message << "\nCalled from #{@caller}." if @caller
    message.join << "\n"
  end

  private
  def extract_date_and_version(version_or_year, month)
    date, version = nil, nil
    if month.nil?
      version = version_or_year
    else
      date = Date.new version_or_year, month, 1
    end
    [date, version]
  end

  def when_deprecation_occurs
    if @date || @version
      after = "on or after "
      after += @date ? @date.strftime("%Y-%m-%d") : "version #{@version}"
    else
      "in a future version"
    end
  end
end

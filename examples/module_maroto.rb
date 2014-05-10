require "optioning"

module Maroto
  def hasherize(*values_and_options)
    optioning = Optioning.new values_and_options
    optioning.deprecate :to_hash, :to, "v2.0.0"
    optioning.deprecation_warn
  end
end

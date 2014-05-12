begin
  require "optioning"
rescue LoadError => e
  $:.unshift File.expand_path "../../lib", __FILE__
  require "optioning"
end

module Maroto
  def hasherize(*values_and_options)
    optioning = Optioning.new values_and_options
    optioning.deprecate :to_hash, :to, "v2.0.0"
    optioning.recognize :persist
    optioning.process caller
  end
end

require_relative "./module_maroto"
class Client
  extend Maroto

  hasherize :some_ivar, to_hash: ->(){}
end

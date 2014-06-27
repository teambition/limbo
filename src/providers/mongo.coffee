mongoose = require 'mongoose'
server = require '../server'
Manager = require '../manager'

class Mongo

  constructor: (@_group) ->
    @_Manager = Manager
    @_isConnected = false
    @_isRpcEnabled = false
    @_managers = {}

  connect: (dsn) ->
    unless @_isConnected
      @mongoose = mongoose.createConnection dsn
      @_isConnected = true
    return this

  load: (modelName, schema) ->
    if arguments.length is 1
      @_loadManager(_modelName, schema) for _modelName, schema of modelName
    else
      @_loadManager modelName, schema
    return this

  _loadManager: (modelName, schema) ->
    schema = schema(mongoose.Schema) if typeof schema is 'function'
    model = @mongoose.model modelName, schema
    managerName = modelName.toLowerCase()
    manager = new @_Manager model
    @[managerName] = manager
    @_managers[managerName] = manager
    return this

  # Set your manager
  manager: (@_Manager) -> this

  # Every model method will be exposed as 'group.model.method'
  # e.g. UserModel.findOne in group 'local' will be exposed as 'local.user.findOne'
  enableRpc: ->
    for managerName, manager of @_managers
      for methodName, method of manager
        if typeof method is 'function'
          do (managerName, methodName, manager) =>
            server.expose "#{@_group}.#{managerName}.#{methodName}", ->
              manager[methodName].apply manager, arguments

module.exports = Mongo

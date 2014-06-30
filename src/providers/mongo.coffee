mongoose = require 'mongoose'
server = require '../server'
Manager = require '../manager'

class Mongo

  limbo = require '../limbo'

  constructor: (@_group) ->
    @_Manager = Manager
    @_isConnected = false
    @_isRpcEnabled = false
    @_managers = {}

  # Dsn of mongo connection
  # e.g. mongodb://localhost:27017/test
  connect: (dsn) ->
    unless @_isConnected
      @mongoose = mongoose.createConnection dsn
      @_isConnected = true
    return this

  # Load mongoose schemas
  # @param `modelName` name of model, the first character is prefered uppercase
  # @param `schema` the mongoose schema instance
  # You can directly set an hash object to this method and it will
  # load all schemas in the object
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
    unless @_isRpcEnabled
      for managerName, manager of @_managers
        for methodName, method of manager
          @_bindRpcMethods(managerName, methodName, manager) if typeof method is 'function'
      @_isRpcEnabled = true
    return this

  # Bind rpc method and emit an event when the callback be called
  # The event name is same as rpc method name 'local.use.findOne'
  _bindRpcMethods: (managerName, methodName, manager) ->
    eventName = "#{@_group}.#{managerName}.#{methodName}"
    server.expose eventName, ->

      _emit = ->
        args = (v for k, v of arguments)
        args.unshift eventName
        limbo.emit.apply limbo, args

      callback = arguments[arguments.length - 1]
      if typeof callback is 'function'
        _callback = =>
          _emit.apply this, arguments
          callback.apply this, arguments
        arguments[arguments.length - 1] = _callback
      else
        _callback = =>
          _emit.apply this, arguments
        arguments[arguments.length] = _callback

      manager[methodName].apply manager, arguments

module.exports = Mongo

mongoose = require 'mongoose'
Server = require '../server'
limbo = require '../limbo'

class Mongo

  constructor: (@_group) ->
    @_isConnected = false
    @_isRpcEnabled = false
    @_isBound = false
    @_server = new Server
    @_models = {}

    # Initial the assists
    # Static -> @statis, @loadStatic, @loadStatics
    ['Static', 'Method', 'Overwrite'].forEach (key) =>
      _mapKey = "#{key.toLowerCase()}s"
      _loadKey = "load#{key}"
      _loadsKey = "load#{key}s"
      @[_mapKey] = {}
      @[_loadKey] = (name, fn) ->
        @[_mapKey][name] = fn
        this
      @[_loadsKey] = (fns) ->
        @[_loadKey](name, fn) for name, fn of fns
        this

  # Load mongoose schemas
  # @param `modelName` name of model, the first character is prefered uppercase
  # @param `schema` the mongoose schema instance
  # You can directly set an hash object to this method and it will
  # load all schemas in the object
  loadSchemas: (schemas) ->
    @loadSchema(modelName, schema) for modelName, schema of schemas
    return this

  loadSchema: (modelName, schema) ->
    modelKey = modelName.toLowerCase()
    schema = schema(mongoose.Schema) if typeof schema is 'function'

    for name, fn of @methods
      schema.methods[name] = fn
    for name, fn of @statics
      schema.statics[name] = fn

    model = @conn.model modelName, schema

    for name, fn of @overwrites
      return unless typeof model[name] is 'function'
      do (name, fn) ->
        _origin = model[name]
        _fn = fn(_origin)
        model[name] = -> _fn.apply model, arguments

    @[modelKey] = model
    @[modelName] = model
    @[modelName + 'Model'] = model
    @_models[modelKey] = model
    return this

  # Dsn of mongo connection
  # e.g. mongodb://localhost:27017/test
  connect: (dsn) ->
    unless @_isConnected
      @conn = mongoose.createConnection dsn
      @_isConnected = true
    return this

  bind: (port) ->
    unless @_isBound
      arguments[0] = Number(port)
      @_server.bind.apply @_server, arguments
      @_isBound = true
    return this

  # Every model method will be exposed as 'group.model.method'
  # e.g. UserModel.findOne in group 'local' will be exposed as 'local.user.findOne'
  enableRpc: ->
    unless @_isRpcEnabled
      for managerName, manager of @_managers
        for methodName, method of manager
          @_bindRpcMethods(managerName, methodName, manager) if typeof method is 'function' and methodName.indexOf('_') isnt 0
      @_isRpcEnabled = true
    return this

  # Bind rpc method and emit an event when the callback be called
  # The event name is same as rpc method name 'local.use.findOne'
  _bindRpcMethods: (managerName, methodName, manager) ->
    eventName = "#{@_group}.#{managerName}.#{methodName}"
    @_server.expose eventName, ->

      _emit = ->
        # Emit event
        args = (v for k, v of arguments)
        args.unshift eventName
        limbo.emit.apply limbo, args

        # Emit all event
        _args = (v for k, v of args)
        _args.unshift '*'
        limbo.emit.apply limbo, _args

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

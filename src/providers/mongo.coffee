mongoose = require 'mongoose'
axon = require 'axon'
rpc = require 'axon-rpc'
limbo = require '../limbo'

rpcServerMap = {}
getRpcServer = (port) ->
  port = Number(port)
  arguments[0] = port
  unless rpcServerMap[port]
    rep = axon.socket 'rep'
    rpcServerMap[port] = server = new rpc.Server rep
    rep.bind.apply rep, arguments
  return rpcServerMap[port]

class Mongo

  constructor: (@group) ->
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

    for name, instanceMethod of @methods
      schema.methods[name] = instanceMethod
    for name, staticMethod of @statics
      schema.statics[name] = staticMethod

    model = @conn.model modelName, schema

    for name, overwriteMethod of @overwrites
      return unless typeof model[name] is 'function'
      do (name, overwriteMethod) ->
        _origin = model[name]
        _overwriteMethod = overwriteMethod(_origin)
        model[name] = -> _overwriteMethod.apply model, arguments

    @[modelKey] = model
    @[modelName + 'Model'] = model
    @_models[modelKey] = model
    return this

  # Dsn of mongo connection
  # e.g. mongodb://localhost:27017/test
  connect: (dsn) ->
    @conn = mongoose.createConnection dsn
    return this

  # Every model method will be exposed as 'group.model.method'
  # e.g. UserModel.findOne in group 'local' will be exposed as 'local.user.findOne'
  enableRpc: ->
    server = getRpcServer.apply this, arguments
    {group} = this

    # Bind rpc method and emit an event when the callback be called
    # The pattern of event name is '#{group}.#{modelKey}.#{methodName}'
    # For example: test.user.findOne
    _bindMethods = (modelKey, methodName, model) ->
      eventName = "#{group}.#{modelKey}.#{methodName}"
      server.expose eventName, ->
        _emit = ->
          # Emit event
          args = (v for k, v of arguments)
          args.unshift eventName
          limbo.emit.apply limbo, args

          # Emit * event
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

        model[methodName].apply model, arguments

    ignoreMethods = ['constructor']

    for modelKey, model of @_models
      for methodName, method of model
        continue unless typeof method is 'function' and methodName.indexOf('_') isnt 0 and methodName not in ignoreMethods
        _bindMethods modelKey, methodName, model

    return this

module.exports = Mongo

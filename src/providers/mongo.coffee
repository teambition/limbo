axon = require 'axon'
rpc = require 'axon-rpc'
limbo = require '../limbo'
{EventEmitter} = require 'events'

class Mongo extends EventEmitter
  getRpcServer: (port, opt) ->
    return @rpcServer if @rpcServer
    rep = axon.socket 'rep'
    @rpcServer = new rpc.Server rep

  constructor: (options) ->
    {conn, group, methods, statics, overwrites, schemas, rpcPort} = options
    throw new Error('missing conn param in mongo provider options') unless conn
    @_group = group

    @_conn = conn
    @_methods = methods or {}
    @_statics = statics or {}
    @_overwrites = overwrites or {}
    @_rpcPort = rpcPort

    @_schemas = {}
    @_models = {}
    @loadSchemas schemas

  loadMethod: (name, fn, schemas) ->
    @_methods[name] = fn
    schema.methods[name] = fn for key, schema of schemas or @_schemas
    this

  loadStatic: (name, fn, schemas) ->
    @_statics[name] = fn
    schema.statics[name] = fn for key, schema of schemas or @_schemas
    this

  loadOverwrite: (name, overwriteMethod, models) ->
    @_overwrites[name] = overwriteMethod

    Object.keys(models or @_models).forEach (key) =>
      model = @_models[key]
      return unless typeof model[name] is 'function'
      _origin = model[name]
      _overwriteMethod = overwriteMethod(_origin)
      model[name] = -> _overwriteMethod.apply model, arguments

    this


  # Load mongoose schemas
  # @param `modelName` name of model, the first character is prefered uppercase
  # @param `schema` the mongoose schema instance
  # You can directly set an hash object to this method and it will
  # load all schemas in the object
  loadSchema: (modelName, schema) ->
    modelKey = modelName.toLowerCase()

    @_schemas[modelKey] = schema

    newSchemas = {}
    newSchemas[modelKey] = schema

    @loadMethods @_methods, newSchemas
    @loadStatics @_statics, newSchemas

    model = @_conn.model modelName, schema

    newModels = {}
    newModels[modelKey] = model

    @[modelKey] = model
    @[modelName + 'Model'] = model
    @_models[modelKey] = model

    @loadOverwrites @_overwrites, newModels

    @bindRpcEvent modelKey if @_rpcPort

    this

  # Alias of load prefixed methods
  loadMethods: (methods, schemas) ->
    @loadMethod(name, fn, schemas) for name, fn of methods
    this

  loadStatics: (statics, schemas) ->
    @loadStatic(name, fn, schemas) for name, fn of statics
    this

  loadOverwrites: (overwrites, models) ->
    @loadOverwrite(name, fn, models) for name, fn of overwrites
    this

  loadSchemas: (schemas) ->
    @loadSchema(modelName, schema) for modelName, schema of schemas
    this

  # Every model method will be exposed as 'group.model.method'
  # e.g. UserModel.findOne in group 'local' will be exposed as 'local.user.findOne'
  bindRpcEvent: (modelKey) ->
    server = @getRpcServer()
    group = @_group
    models = @_models
    model = models[modelKey]
    self = this

    # Bind rpc method and emit an event on each model when the callback be called
    # The pattern of event name is the method name
    # For example: db.user.on 'findOne', (err, user) ->
    _bindMethod = (methodName) ->
      eventName = "#{group}.#{modelKey}.#{methodName}"
      server.expose eventName, ->
        sock = this
        _emit = ->
          modelArgs = (v for k, v of arguments)
          modelArgs.unshift methodName
          model.emit.apply model, modelArgs

          rpcEvents = Array.apply(null, arguments)
          rpcEvents.unshift 'rpc', eventName, sock
          self.emit.apply(self, rpcEvents)

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

        # Call the query method
        model[methodName].apply model, arguments

    ignoredMethods = ['constructor']

    for methodName, method of model
      unless typeof method is 'function' and
             methodName.indexOf('_') isnt 0 and
             methodName not in ignoredMethods
        continue
      _bindMethod methodName

    this

  listen : (options = {}, callback = ->) ->
    return if not @_rpcPort
    # Bind to rpc port
    port = Number(@_rpcPort)
    @rpcServer.sock.set('tls', options.tls) if options.tls
    @rpcServer.sock.bind(port, callback)

module.exports = Mongo

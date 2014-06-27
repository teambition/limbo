mongoose = require 'mongoose'

class Manager

  constructor: (model) ->
    @model = model
    for method, foo of model
      if typeof foo is 'function' and not @[method]?
        do (method, foo) =>
          @[method] = -> foo.apply(model, arguments)

class Mongo

  constructor: (@_group) ->
    @_Manager = Manager
    @_isConnected = false

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
    @[modelName.toLowerCase()] = new @_Manager model
    return this

  manager: (@_Manager) -> this

module.exports = Mongo

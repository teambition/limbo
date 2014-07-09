Client = require '../client'

class Rpc

  constructor: (@_group) ->
    @_isConnected = false
    @_client = new Client

  connect: (dsn, callback = ->) ->
    unless @_isConnected
      @_client.connect dsn
      @_isConnected = true
      @methods (err, methods) =>
        @_bindMethods methods
        callback err
    return this

  _bindMethods: (methods = {}) ->
    for name of methods
      [group, _methods...] = name.split('.')
      continue unless group is @_group
      do (_methods) =>
        @[_methods[0]] or= {}
        @[_methods[0]][_methods[1]] = =>
          args = (v for k, v of arguments)
          args.unshift _methods.join '.'
          @call.apply this, args
    return this

  call: (method) ->
    method = "#{@_group}.#{method}"
    arguments[0] = method
    @_client.call.apply @_client, arguments

  methods: -> @_client.methods.apply @_client, arguments

module.exports = Rpc

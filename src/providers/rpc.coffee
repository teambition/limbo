Client = require '../client'

class Rpc

  constructor: (@_group) ->
    @_isConnected = false
    @_client = new Client

  connect: (dsn) ->
    unless @_isConnected
      @_client.connect dsn
      @_isConnected = true
    return this

  call: (method) ->
    method = "#{@_group}.#{method}"
    arguments[0] = method
    @_client.call.apply @_client, arguments

  methods: -> @_client.methods.apply @_client, arguments

module.exports = Rpc

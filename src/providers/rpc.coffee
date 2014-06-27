client = require '../client'

class Rpc

  constructor: (@_group) ->
    @_isConnected = false

  connect: (dsn) ->
    unless @_isConnected
      client.connect dsn
      @_isConnected = true
    return this

  call: (method) ->
    method = "#{@_group}.#{method}"
    arguments[0] = method
    client.call.apply client, arguments

  methods: -> client.methods.apply client, arguments

module.exports = Rpc

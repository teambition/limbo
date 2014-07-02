axon = require 'axon'
rpc = require 'axon-rpc'

class Client

  constructor: ->
    @_req = axon.socket 'req'
    @_client = new rpc.Client @_req

  connect: -> @_req.connect.apply @_req, arguments

  call: -> @_client.call.apply @_client, arguments

  methods: -> @_client.methods.apply @_client, arguments

module.exports = Client

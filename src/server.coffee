axon = require 'axon'
rpc = require 'axon-rpc'

class Server

  constructor: ->
    @_rep = axon.socket 'rep'
    @_server = new rpc.Server @_rep

  bind: -> @_rep.bind.apply @_rep, arguments

  expose: -> @_server.expose.apply @_server, arguments

module.exports = Server

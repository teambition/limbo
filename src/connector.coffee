class Connector

  constructor: (@group) ->
    @provider = 'mongo'

  connect: (dsn) ->

  provider: (provider) ->
    @provider = provider
    return this

module.exports = Connector

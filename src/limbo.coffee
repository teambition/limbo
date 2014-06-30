server = require './server'
{EventEmitter} = require 'events'

class Limbo extends EventEmitter

  constructor: ->
    @_providers = {}
    @_providerName = 'mongo'

  # Limbo separate the schemas into groups
  # Most time group should be the same as db name
  # So the schemas will be reflected to
  # the collections of the database
  use: (group) ->
    return @_providers[group] if @_providers[group]
    Provider = require "./providers/#{@_providerName}"
    provider = new Provider group
    @_providers[group] = provider
    return provider

  # Set the provider name: (default)mongo / rpc
  provider: (@_providerName) -> this

  # Limbo rpc server should bind to a port
  bind: ->
    server.bind.apply server, arguments
    return this

limbo = new Limbo
limbo.Limbo = Limbo

module.exports = limbo

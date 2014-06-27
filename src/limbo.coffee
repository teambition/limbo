class Limbo

  constructor: ->
    @_providers = {}
    @_providerName = 'mongo'

  use: (group) ->
    return @_providers[group] if @_providers[group]
    Provider = require "./providers/#{@_providerName}"
    provider = new Provider group
    @_providers[group] = provider
    return provider

  provider: (@_providerName) -> this

module.exports = new Limbo

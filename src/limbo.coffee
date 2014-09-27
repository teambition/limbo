{EventEmitter} = require 'events'
Proxy = require './proxy'

class Limbo extends EventEmitter

  constructor: ->
    @_providers = {}

  # Limbo separate the schemas into groups
  # Most time group should be the same as db name
  # So the schemas will be reflected to
  # the collections of the database
  use: (group) ->
    unless @_providers[group]
      @_providers[group] = new Proxy(group)
    return @_providers[group]

limbo = new Limbo
limbo.Limbo = Limbo

module.exports = limbo

class Limbo
  constructor: ->
    @_providers = {}

  # Limbo separate the schemas into groups
  # Most time group should be the same as db name
  # So the schemas will be reflected to
  # the collections of the database
  use: (group, options = {}) ->
    unless @_providers[group]
      {provider} = options
      provider or= 'mongo'
      Provider = require "./providers/#{provider}"
      options.group = group
      @_providers[group] = new Provider options
    @_providers[group]

limbo = new Limbo
limbo.Limbo = Limbo

module.exports = limbo

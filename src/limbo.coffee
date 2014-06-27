class Limbo

  load: (group, model, schema) ->
    return this

  loadGroup: (group, schemas) ->
    for model, schema of schemas
      @load group, model, schema
    return this

  use: (group) ->

module.exports = new Limbo

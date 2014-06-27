class Manager

  constructor: (model) ->
    @model = model
    for method, foo of model
      if typeof foo is 'function' and not @[method]?
        do (method, foo) =>
          @[method] = -> foo.apply(model, arguments)

module.exports = Manager

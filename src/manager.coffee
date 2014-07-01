# __bind from CoffeeScript
_bind = (fn, me) -> -> fn.apply me, arguments
ignoreMethods = ['constructor', 'model']

class Manager

  constructor: (model) ->
    @[methodName] = _bind(method, this) for methodName, method of this when typeof method is 'function' and methodName not in ignoreMethods
    @[methodName] = _bind(method, model) for methodName, method of model when typeof method is 'function' and not @[methodName]?
    @model = model

module.exports = Manager

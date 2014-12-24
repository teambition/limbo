axon = require 'axon'
rpc = require 'axon-rpc'

getRpcClient = (dsn) ->
  req = axon.socket 'req'
  client = new rpc.Client req
  req.connect.apply req, arguments
  return client

class Rpc

  constructor: (options) ->
    {conn, group} = options
    @_group = group
    @_conn = conn
    @connect conn

  connect: (dsn, callback = ->) ->
    @_client = getRpcClient dsn
    group = @_group
    self = this

    _bindMethods = (methods = {}) ->
      for name of methods
        [_group, _methods...] = name.split('.')
        continue unless _group is group
        do (_methods) ->
          self[_methods[0]] or= {}
          self[_methods[0]][_methods[1]] = ->
            args = (v for k, v of arguments)
            args.unshift _methods.join '.'
            self.call.apply self, args
      return self

    @methods (err, methods) ->
      _bindMethods methods
      callback err, methods

    return this

  call: (method) ->
    method = "#{@_group}.#{method}"
    arguments[0] = method
    @_client.call.apply @_client, arguments

  methods: -> @_client.methods.apply @_client, arguments

module.exports = Rpc

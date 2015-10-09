dnode = require 'dnode'
{EventEmitter} = require 'events'

class Rpc extends EventEmitter

  constructor: (options) ->
    {conn, group} = options
    throw new Error('missing conn param in rpc provider options') unless conn
    @_group = group
    @_conn = conn
    @_remote = null
    @connect conn

  connect: (dsn, callback = ->) ->
    client = dnode.connect dsn
    group = @_group
    self = this

    client.on 'remote', (remote) ->
      self._remote = remote
      for name of remote
        [_group, _methods...] = name.split('__')
        continue unless _group is group
        do (_methods) ->
          self[_methods[0]] or= {}
          self[_methods[0]][_methods[1]] = ->
            args = (v for k, v of arguments)
            args.unshift _methods.join '.'
            self.call.apply self, args
      self.emit 'bind'
      return

    return this

  call: (method) ->
    method = method.replace /\./g, '__'
    method = "#{@_group}__#{method}"
    arguments[0] = method

    if toString.call(arguments[arguments.length - 1]) is '[object Function]'
      callback = arguments[arguments.length - 1]
      _callback = (err) ->
        if err?.stack and err?.message
          _err = new Error(err.message)
          _err.stack = err.stack
          return callback _err
        callback.apply this, arguments
      arguments[arguments.length - 1] = _callback

    @_remote[method].apply @_remote, Array.prototype.slice.call(arguments, 1)

module.exports = Rpc

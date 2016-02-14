axon = require 'axon'
rpc = require 'axon-rpc'
{EventEmitter} = require 'events'

getRpcClient = (conn, options = {}) ->
  req = axon.socket 'req'
  client = new rpc.Client req
  req.set('tls', options.tls) if options.tls
  req.set('max retry', 10)
  req.connect conn
  return client

class Rpc extends EventEmitter

  constructor: (options) ->
    {group} = options
    # throw new Error('missing conn param in rpc provider options') unless conn
    @_group = group

  connect: (conn, callback) ->
    if typeof conn is 'string'
      @_client = getRpcClient conn
    else
      @_client = getRpcClient conn.url, conn
    group = @_group
    self = this
    @_client.sock.on('error', (error) -> self.emit('error', error))
    @_client.sock.on('close', -> self.emit('error', new Error('remote rpc closed')))

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
          self[_methods[0]][_methods[1] + 'Async'] = ->
            args = (v for k, v of arguments)
            args.unshift _methods.join '.'
            return new Promise((resolve, reject) ->
              args.push (err, result) ->
                return reject(err) if err
                resolve(result)
              self.call.apply self, args
            );
      return self

    @methods (err, methods) ->
      return callback(err) if err
      _bindMethods methods
      # self.emit 'bind', methods
      callback err, methods
    return this

  call: (method) ->
    method = "#{@_group}.#{method}"
    arguments[0] = method
    @_client.call.apply @_client, arguments

  methods: -> @_client.methods.apply @_client, arguments

module.exports = Rpc

class Proxy

  constructor: (@_groupName) ->

  connect: (url, callback) ->
    providerName = if /^tcp/.test(url) then 'rpc' else 'mongo'
    Provider = require "./providers/#{providerName}"
    @__proto__ = Provider.prototype
    Provider.call(@, @_groupName)
    @connect(url, callback)

module.exports = Proxy

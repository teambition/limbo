axon = require 'axon'
rpc = require 'axon-rpc'
req = axon.socket 'req'
client = new rpc.Client req

client.connect = -> req.connect.apply req, arguments

module.exports = client

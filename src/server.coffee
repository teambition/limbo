axon = require 'axon'
rpc = require 'axon-rpc'
rep = axon.socket 'rep'
server = new rpc.Server rep

server.bind = -> rep.bind.apply rep, arguments

module.exports = server

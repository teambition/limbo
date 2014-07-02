axon = require 'axon'
rpc = require 'axon-rpc'

rep1 = axon.socket 'rep'
server1 = new rpc.Server rep1
rep1.bind 7000
server1.expose 'test', (callback) -> callback null, 1

rep2 = axon.socket 'rep'
server2 = new rpc.Server rep2
rep2.bind 7001
server2.expose 'test', (callback) -> callback null, 2

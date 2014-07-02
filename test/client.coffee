axon = require 'axon'
rpc = require 'axon-rpc'

req1 = axon.socket 'req'
client1 = new rpc.Client req1
req1.connect 7000
client1.call 'test', (err, num) -> console.log num

req2 = axon.socket 'req'
client2 = new rpc.Client req2
req2.connect 7001
client2.call 'test', (err, num) -> console.log num

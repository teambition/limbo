# This service query the mongo db by rpc methods, please execute service1 before

limbo = require '../'

# Then connect to the server and call rpc methods
conn2 = limbo.use('test').connect 'tcp://localhost:7001'

conn2.call 'user.findOne', name: 'Alice', (err, user) -> console.log 'get user Alice', user

# Or: after callback of connect
# You can directly call method chain to get data from remote service
conn2 = limbo.use('test').connect 'tcp://localhost:7001', ->
  conn2.user.findOne name: 'Alice', (err, user) -> console.log 'get user Alice', user

limbo.use('test').call 'user.findOne', name: 'Alice', (err, user) -> console.log 'find user Alice', user

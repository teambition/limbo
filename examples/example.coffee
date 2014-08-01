limbo = require '../'

UserSchema = (Schema) ->
  new Schema
    name: String
    email: String

# Use mongo provider to connect mongodb
# `test` is the group name
conn1 = limbo
  .use 'test'
  .connect '192.168.0.21/test'
  .load 'User', UserSchema

conn1.user.create
  name: 'Alice'
, (err, user) ->
  console.log 'create user Alice', user

# Or connect to the rpc server and query by rpc methods
# First enable the rpc server
limbo.use('test').bind(7001).enableRpc()

# Then connect to the server and call rpc methods
conn2 = limbo
  .use 'test'
  .connect 'tcp://localhost:7001'

conn2.call 'user.findOne',
  name: 'Alice'
, (err, user) ->
  console.log 'get user Alice', user

# Or: after callback of connect
# You can directly call method chain to get data from remote service
conn2 = limbo
  .use 'test'
  .connect 'tcp://localhost:7001', ->
    conn2.user.findOne
      name: 'Alice'
    , (err, user) ->
      console.log 'get user Alice', user

# Manager is a proxy class between provider and model
# You can define manager by your self
class SomeManager extends require('../lib').Manager

  getAlice: (callback) ->
    @model.findOne
      name: 'Alice'
    , callback

conn3 = limbo
  .use 'test'
  .manager SomeManager
  .load 'User', UserSchema
  .connect '192.168.0.21/test'

conn3.user.getAlice (err, user) -> console.log user

# Listen on the event of data manipulations by rpc methods
limbo.on 'test.user.findOne', (err, user) ->
  console.log user

limbo.use('test').call 'user.findOne'
  name: 'Alice'
, (err, user) ->

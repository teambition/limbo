limbo = require '../'
mongoDsn = 'mongodb://localhost/test'

UserSchema = (Schema) ->
  new Schema
    name: String
    email: String

# Use mongo provider to connect mongodb
# `test` is the group name
conn1 = limbo.use('test').connect(mongoDsn).loadSchema 'User', UserSchema

# Use the method chain
conn1.user.create name: 'Alice', (err, user) -> console.log 'create user Alice', user

# Or use model instance
{UserModel} = conn1
user = new UserModel name: 'Bob'
user.save (err, user) -> console.log 'create user Bob', user

# Or connect to the rpc server and query by rpc methods
# First enable the rpc server
limbo.use('test').enableRpc(7001)

# Then connect to the server and call rpc methods
conn2 = limbo.use('test').connect 'tcp://localhost:7001'

conn2.call 'user.findOne', name: 'Alice', (err, user) -> console.log 'get user Alice', user

# Or: after callback of connect
# You can directly call method chain to get data from remote service
conn2 = limbo.use('test').connect 'tcp://localhost:7001', ->
  conn2.user.findOne name: 'Alice', (err, user) -> console.log 'get user Alice', user

# Manager is a proxy class between provider and model
# You can define manager by your self
statics =
  getAlice: (callback) -> @findOne name: 'Alice', callback

conn3 = limbo.use('test').loadStatics(statics).connect(mongoDsn).loadSchema 'User', UserSchema
conn3.user.getAlice (err, user) -> console.log user

# Listen on the event of data manipulations by rpc methods
limbo.on 'test.user.findOne', (err, user) -> console.log user

limbo.use('test').call 'user.findOne', name: 'Alice', (err, user) -> console.log 'find user Alice', user

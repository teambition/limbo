limbo = require '../'

UserSchema = (Schema) ->
  new Schema
    name: String
    email: String

# Use group test and connect to mongodb
conn1 = limbo.use('test').connect('192.168.0.21/test')
conn1.load 'User', UserSchema
conn1.user.create
  name: 'Alice'
, (err, user) ->
  console.log 'create user Alice', user

# Or connect to the rpc server and query by rpc methods
conn2 = limbo.provider('rpc').use('test').connect('tcp://localhost:7001')
conn2.call 'user.findOne',
  name: 'Alice'
, (err, user) ->
  console.log 'get user Alice', user

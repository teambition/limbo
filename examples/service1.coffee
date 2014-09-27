# This service query the mongo db by native mongoose methods

limbo = require '../'
mongoDsn = 'mongodb://localhost/test'

UserSchema = (Schema) ->
  new Schema
    name: String
    email: String
    createdAt: type: Date, default: Date.now
    updatedAt: type: Date, default: Date.now

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

# use the statics/static function to bind static method to all the models
# You can define manager by your self
statics = getAlice: (callback) -> @findOne name: 'Alice', callback

conn3 = limbo.use('test').loadStatics(statics).connect(mongoDsn).loadSchema 'User', UserSchema
conn3.user.getAlice (err, user) -> console.log 'find user Alice by custom method', user

# Overwrite the embeded function
# Update the timestamp on each update call
overwrites =
  findOneAndUpdate: (_update) ->
    (conditions, update) ->
      update.updatedAt = new Date
      _update.apply this, arguments

conn4 = limbo.use('test').loadOverwrites(overwrites).connect(mongoDsn).loadSchema 'User', UserSchema
setTimeout ->
  conn4.user.findOneAndUpdate {name: 'Alice'}, {email: 'new@gmail.com'}, (err, user) -> console.log 'update user Alice', user
, 1000

# Listen on the event of data manipulations by rpc methods
limbo.on 'test.user.findOne', (err, user) -> console.log user

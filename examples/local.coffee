limbo = require '../'
mongoose = require 'mongoose'
{Schema} = mongoose
mongoDsn = 'mongodb://127.0.0.1/test'

UserSchema = new Schema
  name: String
  email: String
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now

schemas = User: UserSchema

# Define instance method on each schema
methods = getName: -> "Mr(s): " + @name

# use the statics/static function to bind static method to all the models
# You can define manager by your self
statics = findAlice: (callback) -> @findOne name: 'Alice', callback

# Overwrite the embeded function
# Update the timestamp on each update call
overwrites =
  findOneAndUpdate: (_update) ->
    (conditions, update) ->
      update.updatedAt = new Date
      _update.apply this, arguments

# Initialize the limbo instance
talkdb = limbo.use 'talk',
  provider: 'mongo'
  conn: mongoose.createConnection mongoDsn
  schemas: schemas
  statics: statics
  methods: methods
  overwrites: overwrites
  rpcPort: 7001  # Enable rpc request and bind to the the port

# Use the method chain
talkdb.user.create name: 'Alice', (err, user) -> console.log 'create user Alice', user

# Or use model instance
{UserModel} = talkdb
bob = new UserModel name: 'Bob'
bob.save (err, user) -> console.log 'create user Bob', user

# Call the instance method of user schema
console.log bob.getName()  # Mr(s): Bob

# Call the static method of user schema
UserModel.findAlice (err, user) -> console.log 'find user Alice', user

# Listen on the event of data manipulations by rpc methods
talkdb.user.on 'findOne', (err, user) -> console.log 'find one user by rpc', user

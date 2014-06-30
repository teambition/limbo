should = require 'should'
mongoDsn = process.env.MONGO_DSN or '192.168.0.21/test'
rpcDsn = 'tcp://localhost:7001'
mongoose = require('mongoose').createConnection mongoDsn
limbo = require '../'

UserSchema = (Schema) ->
  new Schema
    name: String
    email: String

PetSchema = (Schema) ->
  new Schema
    type: String
    age: Number

util =
  dropDb: (done) ->
    mongoose.db.executeDbCommand dropDatabase: 1, done

describe 'Limbo', ->

  # Initial limbo
  before ->
    limbo.bind 7001
      .use 'test'
      .connect mongoDsn
      .load 'User', UserSchema
      .enableRpc()

  # Get mongoose schemas and initial mongo provider
  it 'should load schemas and get a connecter instance', ->
    limbo1 = new limbo.Limbo
    conn = limbo1.use('test').connect mongoDsn
    # Load single schema
    conn.load 'User', UserSchema
    conn.should.have.properties 'user'

  # Create user
  it 'should create user by mongo provider', (done) ->
    limbo1 = new limbo.Limbo
    conn = limbo1.use('test').connect(mongoDsn).load 'User', UserSchema
    conn.user.create
      name: 'Alice'
      email: 'alice@gmail.com'
    , (err, user) ->
      user.should.have.properties '_id', 'name', 'email'
      done err

  # Enable rpc server
  # Call rpc methods and emit an event of same name in server side
  it 'should call rpc method and get back the user named Alice', (done) ->
    limbo1 = new limbo.Limbo
    conn = limbo1
      .provider 'rpc'
      .use 'test'
      .connect rpcDsn

    num = 0
    _callback = (err, user) ->
      num += 1
      return if num > 2
      user.should.have.properties '_id', 'name', 'email'
      done(err) if num is 2

    limbo.on 'test.user.findOne', _callback

    conn.call 'user.findOne',
      name: 'Alice'
    , _callback

  it 'should define a method in manager and call this method', (done) ->
    class Manager extends limbo.Manager

      createDog: (callback) ->
        @model.create
          type: 'dog'
          age: 1
        , callback

    limbo1 = new limbo.Limbo
    conn = limbo1
      .provider 'mongo'
      .use 'test'
      .manager Manager
      .connect mongoDsn
      .load 'Pet', PetSchema
    conn.pet.createDog (err, dog) ->
      dog.should.have.properties '_id', 'type', 'age'
      dog.age.should.eql 1
      done err

  after util.dropDb

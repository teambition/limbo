should = require 'should'
mongoDsn = process.env.MONGO_DSN or '192.168.0.21/test'
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

  # Get mongoose schemas and initial mongo provider
  it 'should load schemas and get a connecter instance', ->
    conn = limbo.use('test').connect mongoDsn
    # Load single schema
    conn.load 'User', UserSchema
    conn.should.have.properties 'user'

  # Create user
  it 'should create user by mongo provider', (done) ->
    conn = limbo.use('test')
    conn.user.create
      name: 'Alice'
      email: 'alice@gmail.com'
    , (err, user) ->
      user.should.have.properties '_id', 'name', 'email'
      done err

  # Enable rpc server
  it 'should enable an rpc server by `enableRpc` function', ->
    limbo.bind(7001).use('test').enableRpc()

  # Call rpc methods
  it 'should call rpc method and get back the user named Alice', (done) ->
    delete limbo._providers['test']  # This is a badly hack, don't use this way in any case.
    conn = limbo.provider('rpc').use('test').connect('tcp://localhost:7001')
    conn.call 'user.findOne',
      name: 'Alice'
    , (err, user) ->
      user.should.have.properties '_id', 'name', 'email'
      done err

  it 'should define a method in manager and call this method', (done) ->
    class Manager extends limbo.Manager

      createDog: (callback) ->
        @model.create
          type: 'dog'
          age: 1
        , callback

    delete limbo._providers['test']  # This is a badly hack, don't use this way in any case.
    conn = limbo
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

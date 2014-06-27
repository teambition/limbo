should = require 'should'
mongoose = require('mongoose').createConnection '192.168.0.21/test'
limbo = require '../'

UserSchema = (Schema) ->
  new Schema
    name: String
    email: String

PetSchema = (Schema) ->
  new Schema
    name: String
    owner: type: Schema.Types.ObjectId, ref: 'User'

util =
  dropDb: (done) ->
    mongoose.db.executeDbCommand dropDatabase: 1, done

describe 'Provider#Mongo', ->

  it 'should load schemas and get a connecter instance', ->
    conn = limbo.use('test').connect('192.168.0.21/test')
    # Load single schema
    conn.load 'User', UserSchema
    conn.should.have.properties 'user'
    # Load schemas by schema hash
    conn.load 'Pet': PetSchema
    conn.should.have.properties 'user', 'pet'

  it 'should create user by mongo provider', (done) ->
    conn = limbo.use('test')
    conn.user.create
      name: 'Alice'
      email: 'alice@gmail.com'
    , (err, user) ->
      user.should.properties '_id', 'name', 'email'
      done err

  # it 'should enable an rpc server by `enableRpc` function', (done) ->
  #   limbo.use('test').enableRpc()

  after util.dropDb

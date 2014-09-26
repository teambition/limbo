should = require 'should'
mongoDsn = process.env.MONGO_DSN or '192.168.0.21/test'
rpcDsn = 'tcp://localhost:7001'
mongoose = require('mongoose').createConnection mongoDsn
limbo = require '../src/index'

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
    limbo.use 'test'
      .connect mongoDsn
      .bind 7001
      .loadSchema 'User', UserSchema
      .enableRpc()

  # describe 'LoadSchema', ->

  #   # Get mongoose schemas and initial mongo provider
  #   it 'should load schemas and get a connecter instance', ->
  #     _limbo = new limbo.Limbo
  #     conn = _limbo.use('test').connect mongoDsn
  #     # Load single schema
  #     conn.load 'User', UserSchema
  #     conn.should.have.properties 'user'

  # describe 'MongoProvider', ->

  #   # Create user
  #   it 'should create user by mongo provider', (done) ->
  #     _limbo = new limbo.Limbo
  #     conn = _limbo.use('test').connect(mongoDsn).load 'User', UserSchema
  #     conn.user.create
  #       name: 'Alice'
  #       email: 'alice@gmail.com'
  #     , (err, user) ->
  #       user.should.have.properties '_id', 'name', 'email'
  #       done err

  # describe 'RpcProvider', ->

  #   # Enable rpc server
  #   # Call rpc methods and emit an event of same name in server side
  #   it 'should call rpc method and get back the user named Alice', (done) ->
  #     _limbo = new limbo.Limbo
  #     conn = _limbo
  #       .use 'test'
  #       .connect rpcDsn, ->
  #         num = 0
  #         _callback = (err, user) ->
  #           num += 1
  #           return if num > 4
  #           user.should.have.properties '_id', 'name', 'email'
  #           done(err) if num is 4

  #         limbo.on 'test.user.findOne', _callback

  #         # Both call by method name or call by method chain will work
  #         conn.call 'user.findOne',
  #           name: 'Alice'
  #         , _callback

  #         conn.user.findOne
  #           name: 'Alice'
  #         , _callback

  #   it 'should call rpc method and subscribe to all events by *', (done) ->
  #     _limbo = new limbo.Limbo
  #     conn = _limbo
  #       .use 'test'
  #       .connect rpcDsn, ->

  #         limbo.on '*', (event, err, user) ->
  #           event.should.eql 'test.user.findOne'
  #           user.should.have.properties '_id', 'name', 'email'
  #           done(err)

  #         conn.call 'user.findOne',
  #           name: "Alice"
  #         , ->

  describe 'CustomMethods', ->

    it 'should define a static method and bind it to all the models', (done) ->

      _limbo = new limbo.Limbo

      _statics =
        createDog: (callback) ->
          @create
            type: 'dog'
            age: 1
          , callback

      conn = _limbo
        .use 'test'
        .connect mongoDsn
        .loadStatics _statics
        .loadSchema 'Pet', PetSchema

      conn.pet.createDog (err, dog) ->
        dog.should.have.properties '_id', 'type', 'age'
        dog.age.should.eql 1
        done err

    it 'should define an instance method and bind it to all the instance', (done) ->

      _limbo = new limbo.Limbo

      _methods = getAge: -> @age

      conn = _limbo.use 'test'
        .connect mongoDsn
        .loadMethods _methods
        .loadSchema 'Pet', PetSchema

      pet = new conn.PetModel type: 'dog', age: 1
      pet.getAge().should.eql 1
      done()

    it 'should define an pre method and bind it to all the schemas', (done) ->
      _limbo = new limbo.Limbo

      _PetSchema = PetSchema limbo.mongoose.Schema

      # The embed hooks should also work
      _PetSchema.pre 'save', (next) ->
        @age += 1
        next()

      conn = _limbo.use 'test'
        .connect mongoDsn
        .loadOverwrite 'create', (_create) ->

          (doc) ->
            doc.age += 1
            _create.apply this, arguments

        .loadSchema 'Pet', _PetSchema

      promise = conn.pet.create {type: 'dog', age: 1}, (err, dog) ->
        dog.should.have.properties '_id', 'type', 'age'
        dog.age.should.eql 3
        done err

      # Still return a promise
      promise.constructor.name.should.eql 'Promise'

  # describe 'MultiPorts', ->

  #   before ->
  #     limbo.use 'test1'
  #       .connect mongoDsn
  #       .bind 7002
  #       .load 'Pet', PetSchema
  #       .enableRpc()

  #   it 'should connect to different ports in different groups', (done) ->
  #     _limbo = new limbo.Limbo
  #     conn1 = _limbo
  #       .use 'test'
  #       .connect 'tcp://localhost:7001'
  #     conn2 = _limbo
  #       .use 'test1'
  #       .connect 'tcp://localhost:7002'

  #     num = 0
  #     _callback = (methods, match, notMatch) ->
  #       num += 1
  #       Object.keys(methods).forEach (method) ->
  #         method.should.match match
  #         method.should.not.match notMatch
  #       done() if num is 2

  #     conn1.methods (err, methods) -> _callback methods, /^test\.user/, /^test1\.pet/
  #     # conn2.methods (err, methods) -> _callback methods, /^test1\.pet/, /^test\.user/

  after util.dropDb

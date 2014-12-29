should = require 'should'
mongoose = require 'mongoose'
{Schema} = mongoose

mongoDsn = process.env.MONGO_DSN or '192.168.0.21/test'
rpcDsn = 'tcp://localhost:7001'
limbo = require '../src/limbo'
{Limbo} = limbo

conn = mongoose.createConnection mongoDsn

UserSchema = new Schema
  name: String
  email: String

PetSchema = new Schema
  type: String
  age: Number

util =
  dropDb: (done) -> conn.db.executeDbCommand dropDatabase: 1, done

describe 'Limbo', ->

  describe 'LoadSchema', ->

    # Get mongoose schemas and initial mongo provider
    it 'should load schemas', ->
      _limbo = new Limbo
      # Initialize group test and load user schema
      dbGroup = _limbo.use 'test',
        conn: conn
        schemas: User: UserSchema
      dbGroup.should.have.properties 'user', 'UserModel'

  describe 'MongoProvider', ->

    # Create user
    it 'should create user by mongo provider', (done) ->
      _limbo = new Limbo
      dbGroup = _limbo.use 'test',
        conn: conn
        schemas: User: UserSchema

      dbGroup.user.create
        name: 'Alice'
        email: 'alice@gmail.com'
      , (err, user) ->
        user.should.have.properties '_id', 'name', 'email'
        done err

  describe 'RpcProvider', ->

    _server = null

    # Initialize the rpc server
    before (done) ->
      _limbo = new Limbo
      _server = _limbo.use 'test',
        conn: conn
        schemas: User: UserSchema
        rpcPort: 7001
      done()

    # Enable rpc server
    # Call rpc methods and emit an event of same name in server side
    it 'should call rpc method and get back the user named Alice', (done) ->
      _limbo = new Limbo
      dbGroup = _limbo.use 'test',
        provider: 'rpc'
        conn: rpcDsn

      # Emit `bind` event when the methods are bound to the client
      dbGroup.on 'bind', (err) ->
        dbGroup.should.have.properties 'user'
        dbGroup.user.findOne name: 'Alice', _callback

      succNum = 0
      _callback = (err, user) ->
        succNum += 1
        return if succNum > 4
        user.should.have.properties '_id', 'name', 'email'
        done err if succNum is 4

      _server.user.on 'findOne', _callback

      dbGroup.call 'user.findOne',
        name: 'Alice'
      , _callback

  describe 'CustomMethods', ->

    it 'should define a static method and bind it to all the models', (done) ->

      _limbo = new Limbo

      statics = createDog: (callback) -> @create {type: 'dog', age: 1}, callback

      dbGroup = _limbo.use 'test',
        conn: conn
        schemas: Pet: PetSchema
        statics: statics

      dbGroup.pet.createDog (err, dog) ->
        dog.should.have.properties '_id', 'type', 'age'
        dog.age.should.eql 1
        done err

    it 'should define an instance method and bind it to all the instance', (done) ->

      _limbo = new Limbo

      methods = getAge: -> @age

      dbGroup = _limbo.use 'test',
        conn: conn
        methods: methods
        schemas: Pet1: PetSchema

      pet = new dbGroup.Pet1Model type: 'dog', age: 1
      pet.getAge().should.eql 1
      done()

    it 'should define an pre method and bind it to all the schemas', (done) ->

      _limbo = new Limbo

      # The embed hooks should also work
      PetSchema.pre 'save', (next) ->
        @age += 1
        next()

      overwrites =
        create: (_create) ->
          (pet) ->
            pet.age += 1
            _create.apply this, arguments

      dbGroup = _limbo.use 'test',
        conn: conn
        overwrites: overwrites
        schemas: Pet: PetSchema

      promise = dbGroup.pet.create {type: 'dog', age: 1}, (err, dog) ->
        dog.should.have.properties '_id', 'type', 'age'
        dog.age.should.eql 3
        done err

      # Still return a promise
      promise.constructor.name.should.eql 'Promise'

  describe 'MultiPorts', ->

    _server = null

    before ->
      _server = limbo.use 'test1',
        conn: conn
        schemas: Pet: PetSchema
        rpcPort: 7002

    it 'should connect to different ports in different groups', (done) ->

      _limbo = new Limbo

      dbGroup1 = _limbo.use 'test',
        provider: 'rpc'
        conn: 'tcp://localhost:7001'

      dbGroup2 = _limbo.use 'test1',
        provider: 'rpc'
        conn: 'tcp://localhost:7002'

      num = 0
      _callback = (methods, match, notMatch) ->
        num += 1
        Object.keys(methods).forEach (method) ->
          method.should.match match
          method.should.not.match notMatch
        done() if num is 2

      dbGroup1.methods (err, methods) -> _callback methods, /^test\.user/, /^test1\.pet/
      dbGroup2.methods (err, methods) -> _callback methods, /^test1\.pet/, /^test\.user/

  after util.dropDb

limbo [![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url]
=====

Data/Message Proxy Middleware

# Deal with what
- A rpc server for querying mongodb.
- Exchange data/message cross applications.
- Listen for the data's change and emit events.

# Providers
- `mongo` query via mongoose api
- `rpc` query via rpc methods

# Overwrite the mongoose model methods

AFAIK, we can use `hooks` or so called `middlewares` to modify the mongoose model object before `save` and `remove` functions, but it does not works on `update` function. There was even leaded to an argument on [github](https://github.com/LearnBoost/mongoose/issues/964), but the maintainers still don't pay their attension on this issue.
So I decide to use some tricks to `overwrite` the mongoose model methods, and make the hooks work. For example, we have an `update` function in model, we need update the `updatedAt` key when we save data by `update` function, we can `overwrite` this function.

```
_update = UserModel.update
UserModel.update = (conditions, update) ->
  update.updatedAt or= new Date
  _update.apply this, arguments
```

In `limbo`, we supply an `overwrite` function to help you overwrite the same name function of each model.

```
limbo = require 'limbo'
db = limbo.use('test').connect('mongodb://localhost/test')
# Overwrite the update function
db.loadOverwrite 'update', (_update) ->
  (conditions, update) ->
    update or= new Date
    _update.apply this, arguments
# Load schemas
db.loadSchema 'User', UserSchema
# Then each update function will auto update the updateAt key when executed
db.user.update()
```

We use a currying way to ensure your function recieve the exactly arguments by the user given. So the origin function of model will give you in the wrapper function (in this example, it is `_update`).

As the same as `loadStatics` and `loadMethods` in limbo, the `loadOverwrite` function also have a plural version: `loadOverwrites`, you can pass a group of overwrite function to it.

# Dependencies
- `mongoose` limbo is based on [mongodb](http://www.mongodb.org) and use [mongoose](https://github.com/LearnBoost/mongoose).
- `axon/axon-rpc` limbo use [axon](https://github.com/visionmedia/axon) as message-oriented middleware, and use [axon](https://github.com/visionmedia/axon-rpc) as rpc middleware.

# Example
[main.coffee](https://github.com/teambition/limbo/blob/master/examples/main.coffee)

# Attention!
Some methods in rpc provider is not enabled, here is some examples:

1. method chain cross functions is not allowed:

  `db.user.find({}).limit(1).exec(callback)` => `db.user.find({}, {limit: 1}, callback)`

2. RegExp in conditions is not allowed:

  `db.user.find({email: /gmail.com/}, {limit: 1}, callback)` => `db.user.aggregate([{$match: {'email': {$regex: 'gmail.com'}}}, {$limit: 1}])`

3. `aggregate` function in mongoose do not auto cast variables to ObjectId or anything else, so you should take case of these variables and do not use them in the `rpc` provider. (for the reason JSON only accept data)

# Changelog
## 0.2.0
- forget manager, use model now
- merge `bind` and `enableRpc` to one method: `enableRpc`
- `loadStatics`, `loadMethods` and `loadOverwrites` in mongo provider
- use the `load` prefix on all loading methods

## 0.1.8
- auto detective provider

## 0.1.7
- auto convert bind port to number

## 0.1.6
- the rpc provider now support method chain (only use it after the connect callback)

## 0.1.5
- move `bind` method to mongo provider
- support connect to different ports in different rpc instance
- remove `_methods` in exposed methods

## 0.1.4
- the managers extends limbo.Manager will bind all methods to the manager itself.

## 0.0.3
- event support for rpc call

## 0.0.2
- support query by mongo/rpc provider
- auto provide a rpc server so you can query via tcp connect

## 0.0.1
- only readme

# Licence
MIT

[npm-url]: https://npmjs.org/package/limbo
[npm-image]: http://img.shields.io/npm/v/limbo.svg

[travis-url]: https://travis-ci.org/teambition/limbo
[travis-image]: http://img.shields.io/travis/teambition/limbo.svg

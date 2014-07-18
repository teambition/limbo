limbo [![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url]
=====

Data/Message Proxy Middleware

# Deal with what
* A rpc server for querying mongodb.
* Exchange data/message cross applications.
* Listen for the data's change and emit events.

# Providers
* `mongo` query via mongoose api
* `rpc` query via rpc methods

# Dependencies
* `mongoose` limbo is based on [mongodb](http://www.mongodb.org) and use [mongoose](https://github.com/LearnBoost/mongoose).
* `axon/axon-rpc` limbo use [axon](https://github.com/visionmedia/axon) as message-oriented middleware, and use [axon](https://github.com/visionmedia/axon-rpc) as rpc middleware.

# Example
[example.coffee](https://github.com/teambition/limbo/blob/master/examples/example.coffee)

# Attention!
Some methods in rpc provider is not enabled, here is some examples:

1. method chain cross functions is not allowed:

  `db.user.find({}).limit(1).exec(callback)` => `db.user.find({}, {limit: 1}, callback)`

2. RegExp in conditions is not allowed:

  `db.user.find({email: /gmail.com/}, {limit: 1}, callback)` => `db.user.aggregate([{$match: {'email': {$regex: 'gmail.com'}}}, {$limit: 1}])`

# Changelog
## 0.1.6
* the rpc provider now support method chain (only use it after the connect callback)

## 0.1.5
* move `bind` method to mongo provider
* support connect to different ports in different rpc instance
* remove `_methods` in exposed methods

## 0.1.4
* the managers extends limbo.Manager will bind all methods to the manager itself.

## 0.0.3
* event support for rpc call

## 0.0.2
* support query by mongo/rpc provider
* auto provide a rpc server so you can query via tcp connect

## 0.0.1
* only readme

# Licence
MIT

[npm-url]: https://npmjs.org/package/limbo
[npm-image]: http://img.shields.io/npm/v/limbo.svg

[travis-url]: https://travis-ci.org/teambition/limbo
[travis-image]: http://img.shields.io/travis/teambition/limbo.svg

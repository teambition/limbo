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

# Changelog
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

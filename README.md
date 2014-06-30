limbo
=====

Data/Message Proxy Middleware

[![build status](https://api.travis-ci.org/teambition/limbo.png)](https://travis-ci.org/teambition/limbo)

# Deal with what
* A rpc server for querying mongodb.
* Exchange data/message cross applications.
* Listen for the data's change and emit events.

# Example
See examples directory

# Providers
* `mongo` query via mongoose api
* `rpc` query via rpc methods

# Dependencies
* `mongoose` limbo is based on [mongodb](http://www.mongodb.org) and use [mongoose](https://github.com/LearnBoost/mongoose).
* `axon/axon-rpc` limbo use [axon](https://github.com/visionmedia/axon) as message-oriented middleware, and use [axon](https://github.com/visionmedia/axon-rpc) as rpc middleware.

# Example

# Changelog
## 0.0.3
* event support for rpc call

## 0.0.2
* support query by mongo/rpc provider
* auto provide a rpc server so you can query via tcp connect

## 0.0.1
* only readme

# Licence
MIT

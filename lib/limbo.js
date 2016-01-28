// Generated by CoffeeScript 1.10.0
(function() {
  var EventEmitter, Limbo, limbo,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  EventEmitter = require('events').EventEmitter;

  Limbo = (function(superClass) {
    extend(Limbo, superClass);

    function Limbo() {
      this._providers = {};
    }

    Limbo.prototype.use = function(group, options) {
      var Provider, provider;
      if (options == null) {
        options = {};
      }
      if (!this._providers[group]) {
        provider = options.provider;
        provider || (provider = 'mongo');
        Provider = require("./providers/" + provider);
        options.group = group;
        this._providers[group] = new Provider(options);
      }
      return this._providers[group];
    };

    return Limbo;

  })(EventEmitter);

  limbo = new Limbo;

  limbo.Limbo = Limbo;

  module.exports = limbo;

}).call(this);
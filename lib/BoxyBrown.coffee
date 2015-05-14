arrayUnique = require('./Utils.coffee').arrayUnique
_console = require('./Console.coffee')
CoffeeJs = require('./CoffeeJs.coffee')
ScssCss = require('./ScssCss.coffee')

fs = require('fs')
browserify = require('browserify')
crypto = require('crypto')
sass = require('node-sass')



buildConfigs = (configs = {}) ->
  clean = 
    route: ''
    source: ''
    debug: false
  
  clean.route = configs.route if configs.route isnt undefined
  clean.source = configs.source if configs.source isnt undefined
  clean.debug = configs.debug if configs.debug isnt undefined
  
  clean


module.exports =
  CoffeeJs: (conf = {}) ->
    virtual = new CoffeeJs(buildConfigs(conf))
    virtual.setUp().express()
  
  ScssCss: (conf = {}) ->
    virtual = new ScssCss(buildConfigs(conf))
    virtual.setUp().express()
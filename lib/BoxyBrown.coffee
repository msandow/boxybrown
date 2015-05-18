CoffeeJs = require('./CoffeeJs.coffee')
ScssCss = require('./ScssCss.coffee')
Tokenized = require('./Tokenized.coffee')
TokenReplacer = require('./TokenReplacer')




buildConfigs = (configs = {}) ->
  clean = 
    route: ''
    source: ''
    debug: false
    tokens: {}
  
  clean.route = configs.route if configs.route isnt undefined
  clean.source = configs.source if configs.source isnt undefined
  clean.debug = configs.debug if configs.debug isnt undefined
  clean.tokens = configs.tokens if configs.tokens isnt undefined
  
  clean


module.exports =
  CoffeeJs: (conf = {}) ->
    virtual = new CoffeeJs(buildConfigs(conf))
    virtual.setUp().express()

  ScssCss: (conf = {}) ->
    virtual = new ScssCss(buildConfigs(conf))
    virtual.setUp().express()

  Tokenized: (conf = {}) ->
    virtual = new Tokenized(buildConfigs(conf))
    virtual.setUp().express()

  TokenReplacer: TokenReplacer
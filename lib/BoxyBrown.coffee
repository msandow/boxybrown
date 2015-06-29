CoffeeJs = require('./CoffeeJs.coffee')
ScssCss = require('./ScssCss.coffee')
LessCss = require('./LessCss.coffee')
Tokenized = require('./Tokenized.coffee')
TokenReplacer = require('./Utils').TokenReplacer
Remote = require('./Remote.coffee')




buildConfigs = (configs = {}) ->
  clean = 
    route: ''
    source: ''
    debug: false
    tokens: {}
    silent: false
  
  clean.route = configs.route if configs.route isnt undefined
  clean.source = configs.source if configs.source isnt undefined
  clean.debug = configs.debug if configs.debug isnt undefined
  clean.tokens = configs.tokens if configs.tokens isnt undefined
  clean.silent = !!configs.silent if configs.silent isnt undefined
  
  clean


module.exports =
  CoffeeJs: (conf = {}) ->
    virtual = new CoffeeJs(buildConfigs(conf))
    virtual.setUp().express()

  ScssCss: (conf = {}) ->
    virtual = new ScssCss(buildConfigs(conf))
    virtual.setUp().express()

  LessCss: (conf = {}) ->
    virtual = new LessCss(buildConfigs(conf))
    virtual.setUp().express()

  Tokenized: (conf = {}) ->
    virtual = new Tokenized(buildConfigs(conf))
    virtual.setUp().express()

  TokenReplacer: TokenReplacer

  Remote: (conf = {}) ->
    virtual = new Remote(buildConfigs(conf))
    virtual.setUp().express()
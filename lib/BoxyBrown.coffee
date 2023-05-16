CoffeeJs = require('./CoffeeJs.coffee')
Js = require('./Js.coffee')
ScssCss = require('./ScssCss.coffee')
LessCss = require('./LessCss.coffee')
Tokenized = require('./Tokenized.coffee')
TokenReplacer = require('./Utils').TokenReplacer
Remote = require('./Remote.coffee')
BuildConfigs = require('./BuildConfigs.coffee')
TypescriptJs = require('./TypescriptJs.coffee')


module.exports =
  CoffeeJs: (conf = {}) ->
    virtual = new CoffeeJs(BuildConfigs(conf))
    virtual.setUp().express()

  Js: (conf = {}) ->
    virtual = new Js(BuildConfigs(conf))
    virtual.setUp().express()

  ScssCss: (conf = {}) ->
    virtual = new ScssCss(BuildConfigs(conf))
    virtual.setUp().express()

  LessCss: (conf = {}) ->
    virtual = new LessCss(BuildConfigs(conf))
    virtual.setUp().express()

  Tokenized: (conf = {}) ->
    virtual = new Tokenized(BuildConfigs(conf))
    virtual.setUp().express()

  TokenReplacer: TokenReplacer

  Remote: (conf = {}) ->
    virtual = new Remote(BuildConfigs(conf))
    virtual.setUp().express()

  TypescriptJs: (conf = {}) ->
    virtual = new TypescriptJs(BuildConfigs(conf))
    virtual.setUp().express()

  console: require('PrettyConsole')
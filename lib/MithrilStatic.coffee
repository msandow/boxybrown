_console = require('./Console.coffee')
fs = require('fs')
utils = require('./Utils.coffee')


buildStaticRoute = (route, module, rootHash, conf) ->
  rootHash[route] = (req, res) ->
    m.toString(module, (html)->
      conf.tokens.compiledHtml = html
      utils.TokenReplacer(conf.htmlTemplate, conf.tokens, (err, data)->
        res.end(err or data)
      )
    , req, res)


module.exports = 

  express: (conf) ->
    if not conf.source
      _console.error("No source file provided to MithrilStatic")
      return
    
    if not conf.htmlTemplate
      _console.error("No HTML template file to serve provided to MithrilStatic")
      return
    
    conf.tokens = {} if typeof conf.tokens isnt 'object'
    
    appFile = require(conf.source)()
    appRoutes = {}
    
    if global.m is undefined
      if conf.mithrilAppFile is undefined
        _console.error("No global m variable and no mithrilAppFile path provided to MithrilStatic")
        return
      require(conf.mithrilAppFile)
    
    if not Array.isArray(appFile)
      _console.error("Mithril app file #{conf.source} doesn't return an array of modules")
      return
    
    for module in appFile
      if Array.isArray(module.route)
        for subRoute in module.route
          buildStaticRoute(subRoute, module, appRoutes, conf)
      else
        buildStaticRoute(module.route, module, appRoutes, conf)
    
    
    (req, res, next)=>
      if req.method is 'GET' and appRoutes[req.originalUrl]
        appRoutes[req.originalUrl](req, res)
        
      else
        next()
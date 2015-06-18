_console = require('./Console.coffee')
fs = require('fs')


#buildStaticRoute = (route, module) ->
#  Router.get(route, (req, res)->
#    fs.readFile("#{__dirname}/../../public/index.html", "utf8", (error, data)->
#      m.toString(module, (html)->
#        res.send(
#          utils.tokenReplacement({
#            content: html
#            keywords: 'foo ,bar'
#            description: 'app'
#          },data)
#        )
#      , req, res)
#    )
#  )


module.exports = 

  express: (conf) ->
    if not conf.source
      _console.error("No source file provided to MithrilStatic")
      return
    
    if not conf.htmlTemplate
      _console.error("No HTML template file to serve provided to MithrilStatic")
      return
    
    appFile = require(conf.source)()
    appRoutes = {}
    console.log(global.m)
    process.exit(1)
    
    if not Array.isArray(appFile)
      _console.error("Mithril app file #{conf.source} doesn't return an array of modules")
      return
    
    for module in appFile
      if Array.isArray(module.route)
        for subRoute in module.route
          buildStaticRoute(subRoute, module, appRoutes)
      else
        buildStaticRoute(module.route, module, appRoutes)


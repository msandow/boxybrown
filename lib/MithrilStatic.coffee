_console = require('./Console.coffee')


module.exports = 

  express: (conf) ->
    if not conf.source
      _console.error("No source file provided to MithrilStatic")
      process.exit(1)
    
    appFile = require(conf.source)
    console.log(appFile())
    process.exit(1)



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
#
#for deskTopModule in desktopStaticApp()
#  if Array.isArray(deskTopModule.route)
#    for subRoute in deskTopModule.route
#      buildStaticRoute(subRoute, deskTopModule)
#  else
#    buildStaticRoute(deskTopModule.route, deskTopModule)
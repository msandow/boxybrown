path = require('path')
args = process.argv
BuildConfigs = require('./BuildConfigs.coffee')
CoffeeJs = require('./CoffeeJs.coffee')
Js = require('./Js.coffee')
ScssCss = require('./ScssCss.coffee')
LessCss = require('./LessCss.coffee')
TypescriptJs = require('./TypescriptJs.coffee')
clz = null

module.exports = ()->
  script = args[1] or ""
  script = script.substring(script.lastIndexOf("/"))
  args = args.slice(2)
  source = path.resolve(__dirname, "..", args[0])

  conf = 
    debug: false
    silent: true
    source: source
    route: path.basename(source)
  
  if args.indexOf('--debug') > -1
    conf.debug = true
    idx = args.indexOf('--debug') > -1
    if args[idx + 1] and !/^--/.test(args[idx + 1])
      conf.route = args[idx + 1]

  switch script
    when '/coffeejs'
      conf.route = conf.route.replace('.coffee','.js')
      clz = CoffeeJs
    when '/js'
      clz = Js
    when '/scsscss'
      conf.route = conf.route.replace('.scss','.css')
      clz = ScssCss
    when '/lesscss'
      conf.route = conf.route.replace('.less','.css')
      clz = LessCss
    when '/typescriptjs'
      conf.route = conf.route.replace('.ts','.js')
      clz = TypescriptJs
  
  new clz(BuildConfigs(conf)).run(->
    if conf.debug and args.indexOf('--map') > -1
      console.log(@compiledSourceMap.contents)
    else
      console.log(@compiledStream.contents)
  )
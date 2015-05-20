fs = require('fs')
_console = require('./Console.coffee')

module.exports = class CompiledFile

  constructor: (conf) ->
    @route = conf.route
    @source = conf.source
    @debug = conf.debug
    @tokens = conf.tokens
    @compiling = false
    @sourceFiles = []
    @withWatchers = {}


  setUp: () ->
    @


  responder: (stringFile, req, res) ->
    if req.headers['if-none-match'] isnt undefined and req.headers['if-none-match'] is stringFile.etag
      res.writeHead(304,
        'ETag': stringFile.etag
        'Content-Type': stringFile.contentType
      )    
      res.end()    
    else
      res.writeHead(200,
        'ETag': stringFile.etag
        'Content-Type': stringFile.contentType
      )
      res.end(stringFile.contents)



  build: () ->
    true



  express: () ->
    (req, res, next)=>
      if req.method is 'GET' and req.originalUrl is @route
        @responder(@compiledStream, req, res)

      else if req.method is 'GET' and req.originalUrl is @route + ".map" and @debug
        @responder(@compiledSourceMap, req, res)
        
      else
        next()



  onBuildError: (msg) ->
    length = ('  ' + new Date().toUTCString()).length + 4
    padd = " "

    while length--
      padd += " "


    lines = msg.toString().split(/\n|\r|\r\n/).map((l, idx)->
      return padd + l if idx > 0
      return l
    ).join("\n")

    _console.error(lines)
    @compiling = false



  setUpWatchers: () ->
    for source in @sourceFiles when @withWatchers[source] is undefined
      @withWatchers[source] = true
      
      fs.watch(source, ()=>
        @build()
      )
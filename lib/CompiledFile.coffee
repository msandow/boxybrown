fs = require('fs')
_console = require('PrettyConsole')

module.exports = class CompiledFile

  BROWSERIFY_EXTS: ['.js', '.coffee', '.ts', '.es', '.es6', '.jsx', '.babel', '.json']
  JSX_EXTS: ['.js', '.ts', '.es', '.es6', '.jsx', '.babel']

  constructor: (conf) ->
    @route = conf.route
    @source = conf.source
    @debug = conf.debug
    @silent = conf.silent
    @tokens = conf.tokens
    @uglifyify = conf.uglifyify
    @secureProtocol = conf.secureProtocol
    @babelify = conf.babelify
    @compiling = false
    @sourceFiles = []
    @hasBuildError = false
    @withWatchers = {}

    @killed = false

    @tearDownItems =
      intervals: []
      watchers: []

    if conf.ttl and !@killed
      @tearDownItems.intervals.push(setInterval(=>
        @build()
      , conf.ttl))

    for p in ['SIGINT', 'SIGTERM', 'SIGUSR1', 'SIGUSR2']
      process.on(p, @tearDown.bind(@))

    @


  setUp: () ->
    @


  tearDown: ->
    @killed = true

    if @tearDownItems.intervals.length
      _console.log(@route, "Clearing #{@tearDownItems.intervals.length} intervals")

      while (i = @tearDownItems.intervals.shift()) != undefined
        clearInterval(i)

    if @tearDownItems.watchers.length
      _console.log(@route, "Closing #{@tearDownItems.watchers.length} watchers")

      while (i = @tearDownItems.watchers.shift()) != undefined
        i.close()


  responder: (stringFile, req, res) ->
    if @compiling
      setTimeout(=>
        @responder(stringFile, req, res)
      , 250)
      
      return
    
    done = ()=>
      if @hasBuildError
        res.writeHead(424)
        res.end()
        return
      
      resOb = 
        'ETag': stringFile.etag
        'Content-Type': stringFile.contentType
        'Cache-Control': 'must-revalidate, post-check=0, pre-check=0'

      if req.headers['if-none-match'] isnt undefined and req.headers['if-none-match'] is stringFile.etag
        res.writeHead(304, resOb)    
        res.end()    
      else
        res.writeHead(200, resOb)
        res.end(if req.method isnt 'HEAD' then stringFile.contents else "")
    
    if typeof @tokens is 'function'
      @build(=>
        done()
      )
    else
      done()



  build: (cb=(->)) ->
    true



  run: (cb) ->
    cb.call(@)



  express: () ->
    (req, res, next)=>
      strippedQuery = req.originalUrl.replace(/(\?.+)?$/gi, '')

      if (req.method is 'GET' or req.method is 'HEAD') and strippedQuery is @route
        @responder(@compiledStream, req, res)

      else if (req.method is 'GET' or req.method is 'HEAD') and strippedQuery is @route + ".map" and @debug
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
    return if @killed

    for source in @sourceFiles when @withWatchers[source] is undefined
      @withWatchers[source] = true

      @tearDownItems.watchers.push(fs.watch(source, {persistent: false}, ()=>
        if !@compiling and !@killed
          _console.log(@route, "Build triggered from #{source}")
        @build()
      ))
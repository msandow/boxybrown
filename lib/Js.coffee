CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
browserify = require('browserify')
arrayUnique = require('./Utils.coffee').arrayUnique
_console = require('PrettyConsole')
uglifyify = require('uglifyify')
Base64 = require('./Base64.coffee')
path = require('path')


module.exports = class Js extends CompiledFile

  buildSourceMap: () ->
    target = "sourceMappingURL="
    point = @compiledStream.lastIndexOf(target) + target.length

    ob = {
      js: @compiledStream.substring(0, point) + "#{@route}.map"
      map: @compiledStream.substring(point)
    }
    
    ob.map = ob.map.substring("data:application/json;charset=utf-8;base64,".length).trim()

    @compiledStream.set(ob.js)
    @compiledSourceMap.set(new Buffer(ob.map, 'base64').toString())




  setUp: (doBuild = true) ->
    @compiledStream = new StringFile('text/javascript')
    @compiledSourceMap = new StringFile('application/json') if @debug
    
    @B = browserify({debug: @debug})
    #@B.transform(Base64.transform)
    @B.transform(uglifyify, { global: true  }) if @uglifyify
    @B.add(@source)
    
    @B.on('file', (file, id, parent)=>
      @sourceFiles.push(file)
    )
    
    @build() if doBuild
    
    @


  build: () ->
    if !@compiling
    
      @compiling = true
      @compiledStream.reset()
      @compiledSourceMap.reset() if @debug
      @sourceFiles = []
      
      @B
        .bundle()
        
        .on('data', (chunk)=>
          @compiledStream.append(chunk)
        )
        
        .on('error', (msg)=>
          @onBuildError(msg)
          @hasBuildError = true
        )
        
        .on('end', ()=>
          @hasBuildError = false
          @sourceFiles = arrayUnique(@sourceFiles)
          
          @buildSourceMap() if @debug
          @setUpWatchers() if @debug
          _console.info("#{path.normalize(@source)} compiled") if @debug and not @silent
          
          @compiling = false
        )


  run: (cb) ->
    @setUp(false)
    
    @B
      .bundle()

      .on('data', (chunk)=>
        @compiledStream.append(chunk)
      )

      .on('error', (msg)=>
        console.error(msg)
        cb.call(@)
      )

      .on('end', ()=>
        @buildSourceMap() if @debug
        cb.call(@)
      )
CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
less = require('less')
arrayUnique = require('./Utils.coffee').arrayUnique
fs = require('fs')
_console = require('./Console.coffee')
path = require('path')


module.exports = class LessCss extends CompiledFile
 
  setUp: () ->
    @compiledStream = new StringFile('text/css')
    @compiledSourceMap = new StringFile('application/json') if @debug
    
    @build()
    
    @


  build: () ->
    if !@compiling
    
      @compiling = true
      @compiledStream.reset()
      @compiledSourceMap.reset() if @debug
      @sourceFiles = []
      
      fs.readFile(@source, 'utf8', (err, data)=>
        if err
          @onBuildError(err.message)
          @compiling = false
          @hasBuildError = true
          return
 
        opts =  
          filename: path.resolve(@source)
        
        if @debug
          opts.sourceMap = {}
          opts.sourceMap.sourceMapURL = @route + ".map"

        less.render(data, opts,
          (err, result) =>
            if err
              @onBuildError(err.message)
              @compiling = false
              @hasBuildError = true
              return

            @hasBuildError = false
            @sourceFiles = arrayUnique(result.imports.push(path.resolve(@source)))
            
            @compiledStream.set(result.css)
            
            if @debug
              @compiledSourceMap.set(result.map)

            @setUpWatchers() if @debug
            _console.info("#{@source} compiled") if @debug and not @silent

            @compiling = false
        )
      )
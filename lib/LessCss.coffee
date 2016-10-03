CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
less = require('less')
arrayUnique = require('./Utils.coffee').arrayUnique
fs = require('fs')
_console = require('PrettyConsole')
path = require('path')
Base64 = require('./Base64.coffee')
path = require('path')


module.exports = class LessCss extends CompiledFile
 
  setUp: (doBuild = true) ->
    @compiledStream = new StringFile('text/css')
    @compiledSourceMap = new StringFile('application/json') if @debug
    
    @build() if doBuild
    
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
          opts.sourceMap = 
            sourceMapURL: @route + ".map"
            outputSourceFiles: true
        
#        Base64.direct(data, opts.filename, (err, newData)=>

        less.render(data, opts,
          (err, result) =>
            if err
              msg = err.message
              msg += " - #{err.file}" if err.file isnt undefined
              msg += " #{err.line}:#{err.column}" if err.line isnt undefined

              @onBuildError(msg)
              @compiling = false
              @hasBuildError = true
              return

            @hasBuildError = false
            @sourceFiles = arrayUnique(result.imports.concat(path.resolve(@source)))

            @compiledStream.set(result.css)

            if @debug
              @compiledSourceMap.set(result.map)

            @setUpWatchers() if @debug
            _console.info("#{path.normalize(@source)} compiled") if @debug and not @silent

            @compiling = false
        )

#        )
      )

  run: (cb) ->
    @setUp(false)
    
    fs.readFile(@source, 'utf8', (err, data)=>
        if err
          console.error(err.message)
          cb.call(@)
          return
 
        opts =  
          filename: path.resolve(@source)
        
        if @debug
          opts.sourceMap = 
            sourceMapURL: @route + ".map"
            outputSourceFiles: true

        less.render(data, opts,
          (err, result) =>
            if err
              console.error(err.message)
              cb.call(@)
              return
            
            @compiledStream.set(result.css)
            
            if @debug
              @compiledSourceMap.set(result.map)
            
            cb.call(@)
        )
      )
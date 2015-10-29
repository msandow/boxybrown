CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
sass = require('node-sass')
arrayUnique = require('./Utils.coffee').arrayUnique
_console = require('./Console.coffee')


module.exports = class ScssCss extends CompiledFile
 
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
      
      sass.render(
        file: @source
        sourceMap: if @debug then @route + ".map" else undefined
        outputStyle: 'compressed'
        sourceMapContents: @debug
      ,
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
        @sourceFiles = arrayUnique(result.stats.includedFiles)
        
        if @debug
          @compiledStream.set(result.css.toString().replace(/(sourceMappingURL=)(.+?)(\s\*\/)/gm, "$1#{@route}.map$3"))
          @compiledSourceMap.set(result.map.toString())
        else
          @compiledStream.set(result.css.toString())

        @setUpWatchers() if @debug
        _console.info("#{@source} compiled") if @debug and not @silent
        
        @compiling = false
      )


  run: (cb) ->
    @setUp(false)

    sass.render(
      file: @source
      sourceMap: if @debug then @route + ".map" else undefined
      outputStyle: 'compressed'
      sourceMapContents: @debug
    ,
    (err, result) =>
      if err
        console.error(err.message)
        cb.call(@)
        return

      if @debug
        @compiledStream.set(result.css.toString().replace(/(sourceMappingURL=)(.+?)(\s\*\/)/gm, "$1#{@route}.map$3"))
        @compiledSourceMap.set(result.map.toString())
      else
        @compiledStream.set(result.css.toString())

      cb.call(@)
    )
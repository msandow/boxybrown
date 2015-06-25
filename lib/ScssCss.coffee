CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
sass = require('node-sass')
arrayUnique = require('./Utils.coffee').arrayUnique
_console = require('./Console.coffee')


module.exports = class ScssCss extends CompiledFile
 
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
      
      sass.render(
        file: @source
        sourceMap: if @debug then @route + ".map" else undefined
        outputStyle: 'compressed'
        sourceMapContents: @debug
      ,
      (err, result) =>
        if err
          @onBuildError(err.message)
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
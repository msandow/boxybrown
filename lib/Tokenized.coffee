CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
_console = require('./Console.coffee')
mime = require('mime')
TokenReplacer = require('./Utils').TokenReplacer


module.exports = class Tokenized extends CompiledFile
 
  setUp: () ->
    @compiledStream = new StringFile(mime.lookup(@source))
    @sourceFiles = [@source]
    @setUpWatchers() if @debug
    @build()
    
    @


  build: () ->
    if !@compiling
    
      @compiling = true
      @compiledStream.reset()
      
      TokenReplacer(@source, @tokens, (err, data)=>
        @compiling = false
        
        if err
          _console.error(err)
          return
        
        @compiledStream.set(data)
        _console.info("#{@source} compiled with #{JSON.stringify(@tokens)}") if @debug 
      )
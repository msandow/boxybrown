CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
_console = require('PrettyConsole')
mime = require('mime')
Base64 = require('./Base64.coffee')
TokenReplacer = require('./Utils').TokenReplacer


module.exports = class Tokenized extends CompiledFile
 
  setUp: (doBuild = true) ->
    @compiledStream = new StringFile(mime.lookup(@source))
    @sourceFiles = [@source]
    @setUpWatchers() if @debug
    @build() if typeof @tokens isnt 'function' and doBuild
    
    @


  build: (cb=(->)) ->
    if !@compiling
      @compiling = true
      @compiledStream.reset()
      
      done = (tokens, cb)=>
        TokenReplacer(@source, tokens, (err, data)=>
          if err
            _console.error(err)
            cb()
            return
          
          Base64.direct(data, @source, (err, newData)=>
            @compiling = false

            if err
              _console.error(err)
              cb()
              return

            @compiledStream.set(newData)
            _console.info("#{@source} compiled with #{JSON.stringify(@tokens)}") if @debug
            cb()
          )
        )
      
      if typeof @tokens is 'function'
        @tokens((tokens)=>
          done(tokens, cb)
        )
      else
        done(@tokens, cb)
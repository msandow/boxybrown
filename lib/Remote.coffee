CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
_console = require('PrettyConsole')
request = require('request')


module.exports = class Remote extends CompiledFile
 
  setUp: (doBuild = true) ->
    @compiledStream = new StringFile('text/html')
    @build() if doBuild
    
    @


  build: () ->
    if !@compiling
      @compiling = true
      @compiledStream.reset()
      
      request(@source, (err, response, body)=>
        @compiling = false
        
        if err or response.statusCode >= 400
          _console.error(err or response.statusCode) unless @silent
          return
        
        @compiledStream.contentType = response?.headers?['content-type']
        @compiledStream.set(body)
        _console.info("#{@source} fetched remotely") if @debug and not @silent
      )
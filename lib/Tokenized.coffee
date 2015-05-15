CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
_console = require('./Console.coffee')
arrayUnique = require('./Utils.coffee').arrayUnique
escapeRegExp = require('./Utils.coffee').escapeRegExp
fs = require('fs')
mime = require('mime')


module.exports = class Tokenized extends CompiledFile
 
  setUp: () ->
    @compiledStream = new StringFile(mime.lookup(@source))
    
    @build()
    
    @


  build: () ->
    if !@compiling
    
      @compiling = true
      @compiledStream.reset()
      
      fs.readFile(@source, {encoding: 'utf-8'}, (err, data)=>
        finds = arrayUnique(data.match(/#\{(.*?)\}/gm))
        replaces = finds.map((f)=>
          str = f.substring(2, f.length-1)
          return if @tokens[str] isnt undefined then @tokens[str] else ''
        )
        
        for find, idx in finds
          data = data.replace(new RegExp(escapeRegExp(find),'gm'), replaces[idx])
        
        @compiledStream.set(data)
        
        _console.info("#{@source} compiled with #{JSON.stringify(@tokens)}") if @debug
        
        @compiling = false
      )

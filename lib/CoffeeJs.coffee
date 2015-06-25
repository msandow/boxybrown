CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
browserify = require('browserify')
arrayUnique = require('./Utils.coffee').arrayUnique
_console = require('./Console.coffee')
uglifyify = require('uglifyify')
coffeeify = require('coffeeify')


module.exports = class CoffeeJs extends CompiledFile

  buildSourceMap: () ->
    target = "sourceMappingURL="
    point = @compiledStream.indexOf(target) + target.length
    
    ob = {
      js: @compiledStream.substring(0, point) + "#{@route}.map"
      map: @compiledStream.substring(point)
    }
    
    ob.map = ob.map.substring("data:application/json;base64,".length)
    
    @compiledStream.set(ob.js)
    @compiledSourceMap.set(new Buffer(ob.map, 'base64').toString())




  setUp: () ->
    @compiledStream = new StringFile('text/javascript')
    @compiledSourceMap = new StringFile('application/json') if @debug
    
    @B = browserify({debug: @debug})
    @B.transform(coffeeify)
    @B.transform(uglifyify)
    @B.add(@source)
    
    @B.on('file', (file, id, parent)=>
      @sourceFiles.push(file)
    )
    
    @build()
    
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
          _console.info("#{@source} compiled") if @debug and not @silent
          
          @compiling = false
        )
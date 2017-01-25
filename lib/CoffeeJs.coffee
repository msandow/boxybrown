CompiledFile = require('./CompiledFile.coffee')
StringFile = require('./StringFile.coffee')
browserify = require('browserify')
arrayUnique = require('./Utils.coffee').arrayUnique
_console = require('PrettyConsole')
uglifyify = require('uglifyify')
coffeeify = require('coffeeify')
Base64 = require('./Base64.coffee')
fs = require('fs')
path = require('path')


module.exports = class CoffeeJs extends CompiledFile
  
  sourceMapReformat: ->
    tree = JSON.parse(@compiledSourceMap.contents)
    
    for source, idx in tree.sources when /\.coffee$/.test(source)
      tree.sourcesContent[idx] = fs.readFileSync(source, 'utf8')
    
    @compiledSourceMap.set(JSON.stringify(tree))



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
    #@sourceMapReformat()


  setUp: (doBuild = true) ->
    @compiledStream = new StringFile('text/javascript')
    @compiledSourceMap = new StringFile('application/json') if @debug
    
    @B = browserify({debug: @debug, extensions: ['.coffee']})
    #@B.transform(Base64.transform)
    @B.transform(coffeeify, {sourceMap: true})
    @B.transform(uglifyify)
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
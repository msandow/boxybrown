require('mocha')
expect = require('chai').expect
base = require('./base.coffee')
Boxy = require('./../lib/BoxyBrown.coffee')
async = require('async')
exec = require('child_process').exec

suite = new base().set(
  'TypescriptJs':

    'Should serve JS on route with no map': (done) ->
      
      @router.use(Boxy.TypescriptJs(
        route: '/js/js.js'
        source: "#{__dirname}/files/basic.ts"
        debug: false
        silent: true
      ))
      
      async.series([
        (cb)=>
          setTimeout(cb,@timeout)
        
        
        (cb)=>
          @request('/js/js2.js', (err, response, body)=>
            expect(response.statusCode).to.equal(404)

            cb()
          )
        
        (cb)=>
          @request('/js/js.js', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            expect(body.indexOf('"./include"')).to.be.above(-1)
            expect(body.indexOf('console.log(')).to.be.above(-1)
            expect(body.indexOf('sourceMappingURL')).to.equal(-1)

            cb()
          )
          
        (cb)=>
          @request('/js/js.js.map', (err, response, body)=>
            expect(response.statusCode).to.equal(404)

            cb()
          )

      ],()->
        done()
      )


    'Should serve JS with JSX': (done) ->
      
      @router.use(Boxy.TypescriptJs(
        route: '/js/js4.js'
        source: "#{__dirname}/files/jsx.ts"
        debug: false
        silent: true
        babelify: true
      ))
      
      async.series([
        (cb)=>
          setTimeout(cb,@timeout)
      
        (cb)=>
          @request('/js/js4.js', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            expect(/createElement\(['"]input/i.test(body)).to.equal(true)
            expect(body.indexOf('sourceMappingURL')).to.equal(-1)

            cb()
          )
          
        (cb)=>
          @request('/js/js4.js.map', (err, response, body)=>
            expect(response.statusCode).to.equal(404)

            cb()
          )

      ],()->
        done()
      )


    'Should serve status codes for ETAGs': (done) ->
      tag = "717b0b19f580aea480d699d409155252"

      async.series([
        (cb)=>
          @request('/js/js.js', (err, response, body)=>
            expect(response.headers.etag).to.equal(tag)
            expect(response.statusCode).to.equal(200)
            expect(body.length).to.be.above(0)
            cb()
          )
          
        (cb)=>
          @request({
            url: '/js/js.js'
            headers:
              'if-none-match': tag
          }, (err, response, body)=>
            expect(response.statusCode).to.equal(304)
            expect(body.length).to.equal(0)
            cb()
          )
          
      ], ()->
        done()
      )


    'Should serve JS on route with map': (done) ->
      
      @router.use(Boxy.TypescriptJs(
        route: '/js/js2.js'
        source: "#{__dirname}/files/basic.ts"
        debug: true
        silent: true
      ))
      
      async.series([
        (cb)=>
          setTimeout(cb,@timeout)
        
        (cb)=>
          @request('/js/js2.js', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            expect(body.indexOf('"./include"')).to.be.above(-1)
            expect(body.indexOf('console.log(')).to.be.above(-1)
            expect(body.indexOf('//# sourceMappingURL=/js/js2.js.map')).to.be.above(-1)
            expect(body.indexOf('//# sourceMappingURL=')).to.equal(body.lastIndexOf('//# sourceMappingURL='))

            cb()
          )
          
        (cb)=>
          @request('/js/js2.js.map', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            #expect(body.indexOf('//# sourceMappingURL=')).to.equal(-1)
            expect(body.indexOf('"tests/files/basic.ts"')).to.be.above(-1)
            
            cb()
          )

      ],()->
        done()
      )

    'Should compare CLI and server output': (done) ->

      async.series([
        (cb)=>
          @request('/js/js2.js', (err, response, body)=>
            cmd = "bin/typescriptjs tests/files/basic.ts --debug /js/js2.js"

            exec(cmd, (err, stdout, stderr)=>
              expect(stdout.trim()).to.equal(body)
              cb()
            )
          )
          
        (cb)=>
          @request('/js/js2.js.map', (err, response, body)=>
            cmd = "bin/typescriptjs tests/files/basic.ts --debug /js/js2.js --map"

            exec(cmd, (err, stdout, stderr)=>
              expect(stdout.trim()).to.equal(body)
              cb()
            )
          )
          
      ],()->
        done()
      )


).test()
require('mocha')
expect = require('chai').expect
base = require('./base.coffee')
Boxy = require('./../lib/BoxyBrown.coffee')
async = require('async')
exec = require('child_process').exec

suite = new base().set(
  'Js':

    'Should serve JS on route with no map': (done) ->
      
      @router.use(Boxy.Js(
        route: '/js/js.js'
        source: "#{__dirname}/files/basic.js"
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
            expect(body.indexOf('"./include.js"')).to.be.above(-1)
            expect(body.indexOf('console.log(myArr)')).to.be.above(-1)
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


    'Should serve status codes for ETAGs': (done) ->
      async.series([
        (cb)=>
          @request('/js/js.js', (err, response, body)=>
            expect(response.headers.etag).to.equal("ce3c37cfb64fca53a760ba7e07a77423")
            expect(response.statusCode).to.equal(200)
            expect(body.length).to.be.above(0)
            cb()
          )
          
        (cb)=>
          @request({
            url: '/js/js.js'
            headers:
              'if-none-match': 'ce3c37cfb64fca53a760ba7e07a77423'
          }, (err, response, body)=>
            expect(response.statusCode).to.equal(304)
            expect(body.length).to.equal(0)
            cb()
          )
          
      ], ()->
        done()
      )


    'Should serve JS on route with map': (done) ->
      
      @router.use(Boxy.CoffeeJs(
        route: '/js/js2.js'
        source: "#{__dirname}/files/basic.js"
        debug: true
        silent: true
      ))
      
      async.series([
        (cb)=>
          setTimeout(cb,@timeout)
        
        (cb)=>
          @request('/js/js2.js', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            expect(body.indexOf('"./include.js"')).to.be.above(-1)
            expect(body.indexOf('console.log(myArr)')).to.be.above(-1)
            expect(body.indexOf('//# sourceMappingURL=/js/js2.js.map')).to.be.above(-1)
            expect(body.indexOf('//# sourceMappingURL=')).to.equal(body.lastIndexOf('//# sourceMappingURL='))

            cb()
          )
          
        (cb)=>
          @request('/js/js2.js.map', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            expect(body.indexOf('//# sourceMappingURL=')).to.equal(-1)
            expect(body.indexOf('"/Users/msandow/BoxyBrown/tests/files/basic.js"')).to.be.above(-1)
            
            cb()
          )

      ],()->
        done()
      )

    'Should compare CLI and server output': (done) ->
      async.series([
        (cb)=>
          @request('/js/js2.js', (err, response, body)=>
            cmd = "bin/js tests/files/basic.js --debug /js/js2.js"

            exec(cmd, (err, stdout, stderr)=>
              expect(stdout.trim()).to.equal(body)
              cb()
            )
          )
          
        (cb)=>
          @request('/js/js2.js.map', (err, response, body)=>
            cmd = "bin/js tests/files/basic.js --debug /js/js2.js --map"

            exec(cmd, (err, stdout, stderr)=>
              expect(stdout.trim()).to.equal(body)
              cb()
            )
          )
          
      ],()->
        done()
      )


).test()
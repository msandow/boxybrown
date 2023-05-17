require('mocha')
expect = require('chai').expect
base = require('./base.coffee')
Boxy = require('./../lib/BoxyBrown.coffee')
async = require('async')
exec = require('child_process').exec

suite = new base().set(
  'CoffeeJs':

    'Should serve JS on route with no map': (done) ->
      
      @router.use(Boxy.CoffeeJs(
        route: '/js/js.js'
        source: "#{__dirname}/files/basic.coffee"
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
            expect(body.indexOf('"./include.coffee"')).to.be.above(-1)
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


    'Should serve JS with JSX': (done) ->
      
      @router.use(Boxy.CoffeeJs(
        route: '/js/js4.js'
        source: "#{__dirname}/files/jsx.coffee"
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
      tag = "9058846bb2a4b2238af14a234e25c77b"

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
      
      @router.use(Boxy.CoffeeJs(
        route: '/js/js2.js'
        source: "#{__dirname}/files/basic.coffee"
        debug: true
        silent: true
      ))
      
      async.series([
        (cb)=>
          setTimeout(cb,@timeout)
        
        (cb)=>
          @request('/js/js2.js', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            expect(body.indexOf('"./include.coffee"')).to.be.above(-1)
            expect(body.indexOf('console.log(myArr)')).to.be.above(-1)
            #expect(body.indexOf('//# sourceMappingURL=/js/js2.js.map')).to.be.above(-1)
            expect(body.indexOf('//# sourceMappingURL=')).to.equal(body.lastIndexOf('//# sourceMappingURL='))

            cb()
          )
          
        (cb)=>
          @request('/js/js2.js.map', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            expect(body.indexOf('//# sourceMappingURL=')).to.equal(-1)
            #expect(body.indexOf('module.exports = do->')).to.be.above(-1)
            expect(body.indexOf('"tests/files/basic.coffee"')).to.be.above(-1)
            
            cb()
          )

      ],()->
        done()
      )

    'Should compare CLI and server output': (done) ->
      async.series([
        (cb)=>
          @request('/js/js2.js', (err, response, body)=>
            cmd = "bin/coffeejs tests/files/basic.coffee --debug /js/js2.js"

            exec(cmd, (err, stdout, stderr)=>
              expect(stdout.trim()).to.equal(body)
              cb()
            )
          )
          
        (cb)=>
          @request('/js/js2.js.map', (err, response, body)=>
            cmd = "bin/coffeejs tests/files/basic.coffee --debug /js/js2.js --map"

            exec(cmd, (err, stdout, stderr)=>
              expect(stdout.trim()).to.equal(body)
              cb()
            )
          )
          
      ],()->
        done()
      )

#    'Should replace BASE64 Token': (done) ->
#      @router.use(Boxy.CoffeeJs(
#        route: '/js/js3.js'
#        source: "#{__dirname}/files/base64.coffee"
#        debug: true
#        silent: true
#      ))
#      
#      async.series([
#        (cb)=>
#          setTimeout(cb,@timeout)
#        
#        (cb)=>
#          @request('/js/js3.js', (err, response, body)=>
#            expect(response.statusCode).to.equal(200)
#            expect(body.indexOf('data:image/png;base64,iVBORw0KG')).to.be.above(-1)
#            expect(body.indexOf('//# sourceMappingURL=/js/js3.js.map')).to.be.above(-1)
#            expect(body.indexOf('//# sourceMappingURL=')).to.equal(body.lastIndexOf('//# sourceMappingURL='))
#
#            cb()
#          )
#
#      ],()->
#        done()
#      )


).test()
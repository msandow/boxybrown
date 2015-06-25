require('mocha')
expect = require('chai').expect
base = require('./base.coffee')
Boxy = require('./../lib/BoxyBrown.coffee')
async = require('async')

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
            expect(body.indexOf('//# sourceMappingURL=/js/js2.js.map')).to.be.above(-1)

            cb()
          )
          
        (cb)=>
          @request('/js/js2.js.map', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            expect(body.indexOf('"/Users/msandow/BoxyBrown/tests/files/basic.coffee"')).to.be.above(-1)
            
            cb()
          )

      ],()->
        done()
      )


).test()
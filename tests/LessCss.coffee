require('mocha')
expect = require('chai').expect
base = require('./base.coffee')
Boxy = require('./../lib/BoxyBrown.coffee')
async = require('async')
exec = require('child_process').exec


suite = new base().set(
  'LessCss':

    'Should serve CSS on route with no map': (done) ->
      
      @router.use(Boxy.LessCss(
        route: '/css/css.css'
        source: "#{__dirname}/files/basic.less"
        debug: false
        silent: true
      ))
      
      async.series([
        (cb)=>
          setTimeout(cb,@timeout)
        
        
        (cb)=>
          @request('/css/css2.css', (err, response, body)=>
            expect(response.statusCode).to.equal(404)

            cb()
          )
        
        (cb)=>
          @request('/css/css.css', (err, response, body)=>
            body = body.replace(/\r|\n|\r\n/gim, '')

            expect(response.statusCode).to.equal(200)
            expect(body.indexOf('height: 100%')).to.be.above(-1)
            expect(body.indexOf('sourceMappingURL')).to.equal(-1)

            cb()
          )
          
        (cb)=>
          @request('/css/css.css.map', (err, response, body)=>
            expect(response.statusCode).to.equal(404)

            cb()
          )

      ],()->
        done()
      )


    'Should serve CSS on route with map': (done) ->
      
      @router.use(Boxy.LessCss(
        route: '/css/css2.css'
        source: "#{__dirname}/files/basic.less"
        debug: true
        silent: true
      ))
      
      async.series([
        (cb)=>
          setTimeout(cb,@timeout)
        
        (cb)=>
          @request('/css/css2.css', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            expect(body.indexOf('height: 100%')).to.be.above(-1)
            expect(body.indexOf('/*# sourceMappingURL=/css/css2.css.map */')).to.be.above(-1)

            cb()
          )
          
        (cb)=>
          @request('/css/css2.css.map', (err, response, body)=>
            expect(response.statusCode).to.equal(200)
            expect(body.indexOf('"/Users/msandow/BoxyBrown/tests/files/body.less"')).to.be.above(-1)
            expect(body.indexOf('"/Users/msandow/BoxyBrown/tests/files/body.less"')).to.equal(body.lastIndexOf('"/Users/msandow/BoxyBrown/tests/files/body.less"'))

            cb()
          )

      ],()->
        done()
      )


    'Should compare CLI and server output': (done) ->
      async.series([
        (cb)=>
          @request('/css/css2.css', (err, response, body)=>
            cmd = "bin/lesscss tests/files/basic.less --debug /css/css2.css"

            exec(cmd, (err, stdout, stderr)=>
              expect(stdout.trim()).to.equal(body)
              cb()
            )
          )
          
        (cb)=>
          @request('/css/css2.css.map', (err, response, body)=>
            cmd = "bin/lesscss tests/files/basic.less --debug /css/css2.css --map"

            exec(cmd, (err, stdout, stderr)=>
              expect(stdout.trim()).to.equal(body)
              cb()
            )
          )
          
      ],()->
        done()
      )

).test()
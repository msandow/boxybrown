require('mocha')
expect = require('chai').expect
base = require('./base.coffee')
Boxy = require('./../lib/BoxyBrown.coffee')
async = require('async')

suite = new base().set(
  'Remote':

    'Should serve JS remote file': (done) ->
      @router.get('/fakefile.js', (req,res,next)->
        res.set('Content-Type', 'application/javascript')
        res.end('alert(\'foo\');')
      )
      
      @router.use(Boxy.Remote(
        route: '/fetch.js'
        source: 'http://localhost:'+@port+'/fakefile.js'
        debug: false
        silent: true
      ))
      
      async.series([  
        (cb)=>
          setTimeout(cb,@timeout)
        
        (cb)=>
          @request('/fetch.js', (err, response, body)=>
            expect(response.headers['content-type']).to.equal('application/javascript')
            expect(response.statusCode).to.equal(200)
            expect(body).to.equal("alert('foo');")

            cb()
          )

      ],()->
        done()
      )


).test()
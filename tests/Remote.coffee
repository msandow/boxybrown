require('mocha')
expect = require('chai').expect
base = require('./base.coffee')
Boxy = require('./../lib/BoxyBrown.coffee')
async = require('async')

suite = new base().set(
  'Remote':

    'Should serve JS remote file': (done) ->
      remoteContent = "alert('foo');"
    
      @router.get('/fakefile.js', (req,res,next)->
        res.set('Content-Type', 'application/javascript; charset=utf-8')
        res.end(remoteContent)
      )
      
      @router.use(Boxy.Remote(
        route: '/fetch.js'
        source: 'http://localhost:'+@port+'/fakefile.js'
        debug: false
        silent: true
        ttl: 1000
      ))
      
      async.series([  
        (cb)=>
          setTimeout(cb,@timeout)
        
        (cb)=>
          @request('/fetch.js', (err, response, body)=>
            expect(response.headers['content-type']).to.equal('application/javascript; charset=utf-8')
            expect(response.statusCode).to.equal(200)
            expect(body).to.equal("alert('foo');")
            
            remoteContent = "alert('bar');"
            
            cb()
          )
        
        (cb)=>
          setTimeout(->
            cb()
          ,1000)
        
        (cb)=>
          @request('/fetch.js', (err, response, body)=>
            expect(response.headers['content-type']).to.equal('application/javascript; charset=utf-8')
            expect(response.statusCode).to.equal(200)
            expect(body).to.equal("alert('bar');")

            cb()
          )
      ],()->
        done()
      )


).test()
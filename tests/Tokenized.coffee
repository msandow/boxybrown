require('mocha')
expect = require('chai').expect
base = require('./base.coffee')
Boxy = require('./../lib/BoxyBrown.coffee')
async = require('async')

suite = new base().set(
  'Tokenized':

    'Should serve TXT file with nested replaces - sync': (done) ->
      
      @router.use(Boxy.Tokenized(
        route: '/sitemap.text'
        source: "#{__dirname}/files/base.txt"
        debug: false
        silent: true
        tokens:
          agent: '*'
          disallow: '#{agent}'
      ))
      
      async.series([  
        (cb)=>
          setTimeout(cb,@timeout)
        
        (cb)=>
          @request('/sitemap.text', (err, response, body)=>
            expect(response.headers['content-type']).to.equal('text/plain')
            expect(response.statusCode).to.equal(200)
            expect(body).to.equal("""
This is some file content

  User-agent: *
  Disallow: *
  
            """)

            cb()
          )

      ],()->
        done()
      )
      
      
    'Should serve TXT file with nested replaces - async': (done) ->
      
      @router.use(Boxy.Tokenized(
        route: '/sitemap2.text'
        source: "#{__dirname}/files/base.txt"
        debug: false
        silent: true
        tokens: (done)->
          setTimeout(()->
            done(
              agent: 'Firefox'
            )
          ,1000)
      ))
      
      async.series([  
        (cb)=>
          setTimeout(cb,@timeout)
        
        (cb)=>
          @request('/sitemap2.text', (err, response, body)=>
            expect(response.headers['content-type']).to.equal('text/plain')
            expect(response.statusCode).to.equal(200)
            expect(body).to.equal("""
This is some file content

  User-agent: Firefox
  Disallow: 
  
            """)

            cb()
          )

      ],()->
        done()
      )

#    'Should replace BASE64 Token': (done) ->
#      
#      @router.use(Boxy.Tokenized(
#        route: '/sitemap3.text'
#        source: "#{__dirname}/files/base64.txt"
#        debug: false
#        silent: true
#        tokens: 
#          image: './test.png'
#      ))
#      
#      async.series([
#        (cb)=>
#          setTimeout(cb,@timeout)
#        
#        (cb)=>
#          @request('/sitemap3.text', (err, response, body)=>
#            expect(response.headers['content-type']).to.equal('text/plain')
#            expect(response.statusCode).to.equal(200)
#            expect(body.indexOf('data:image/png;base64,iVBORw0KG')).to.be.above(-1)
#
#            cb()
#          )
#
#      ],()->
#        done()
#      )



).test()
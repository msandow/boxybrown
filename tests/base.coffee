express = require('express')
request = require('request')

module.exports = class
  constructor:  ->
    process.setMaxListeners(50)
    @server = null
    @app = null
    @router = null
    @suite = {}
    @port = 8875
    @timeout = 250
    
    @
  
  before: ->
    @router = new express.Router()
    @app = express()
    @server = @app.listen(@port)
  
  after: ->
    @server.close()
  
  set: (suite)->
    @suite = suite
    @

  request: (url, cb)->
    if typeof url is 'object'
      url.url = 'http://localhost:' + @port + url.url
    else
      url = 'http://localhost:' + @port + url
      
    request(url, cb)
    @
  
  test: ->
    self = @

    for own testdesc, testit of @suite
      describe(testdesc, ->

        this.timeout(15000)
      
        before(()->
          self.before.call(self)
          self.app.use(self.router)
        )
        after(self.after.bind(self))
        
        for own testitname, test of testit
          it(testitname, test.bind(self))
      )
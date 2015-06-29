express = require('express')
request = require('request')

module.exports = class
  constructor:  ->
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
    request('http://localhost:'+@port+url, cb)
    @
  
  test: ->
    self = @

    for own testdesc, testit of @suite
      describe(testdesc, ->
        this.timeout(5000)
      
        before(()->
          self.before.call(self)
          self.app.use(self.router)
        )
        after(self.after.bind(self))
        
        for own testitname, test of testit
          it(testitname, test.bind(self))
      )
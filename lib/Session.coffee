_console = require('./Console.coffee')
session = require('express-session')
uuid = require('uuid')
FileStore = require('session-file-store')(session)
os = require('os')


module.exports = (conf = {}) ->
  if not conf.secret
    _console.error("BoxyBrown Session method must be provided a secret key")
    return
    
  
  session(
    genid: (req)->
      return uuid.v4()
    secret: conf.secret
    saveUninitialized: true
    resave: true
    store: new FileStore(
      path: os.tmpdir()
      logFn: _console.log
    )
  )
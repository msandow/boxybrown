_console = require('./Console.coffee')
session = require('express-session');
uuid = require('uuid');


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
  )
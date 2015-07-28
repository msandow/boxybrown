module.exports = (configs = {}) ->
  clean = 
    route: ''
    source: ''
    debug: false
    tokens: {}
    silent: false
  
  clean.route = configs.route if configs.route isnt undefined
  clean.source = configs.source if configs.source isnt undefined
  clean.debug = configs.debug if configs.debug isnt undefined
  clean.tokens = configs.tokens if configs.tokens isnt undefined
  clean.silent = !!configs.silent if configs.silent isnt undefined
  
  clean
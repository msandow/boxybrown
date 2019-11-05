module.exports = (configs = {}) ->
  clean = 
    route: ''
    source: ''
    debug: false
    tokens: {}
    silent: false
    ttl: false
    uglifyify: true
    secureProtocol: false
    sassIncludePaths: []
  
  clean.route = configs.route if configs.route isnt undefined
  clean.source = configs.source if configs.source isnt undefined
  clean.debug = configs.debug if configs.debug isnt undefined
  clean.tokens = configs.tokens if configs.tokens isnt undefined
  clean.silent = !!configs.silent if configs.silent isnt undefined
  clean.ttl = Math.max(parseInt(configs.ttl),1) if configs.ttl isnt undefined
  clean.uglifyify = configs.uglifyify if configs.uglifyify isnt undefined 
  clean.secureProtocol = configs.secureProtocol if configs.secureProtocol isnt undefined
  clean.sassIncludePaths = configs.sassIncludePaths if configs.sassIncludePaths isnt undefined
  
  
  clean
fs = require('fs')
path = require('path')
mime = require('mime')
async = require('async')
through = require('through')


escapeRegExp = (str)->
  str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")


baseReg = /%BASE64\(['"][a-zA-Z0-9_\-.+?\/]+['"]\)%/m


base = {}


base.direct = (str, sourcePath, cb)->
  if baseReg.test(str)

    sourcePath = path.dirname(sourcePath)
    matchHash = {}

    for match in str.match(baseReg)
      ex = match.substring(9, match.length-3)
      matchHash[match] = path.resolve(sourcePath, ex)

    for own k,v of matchHash
      do (k,v)->
        matchHash[k] = (cb2)->          
          fs.readFile(v, (err, data)->
            cb2(err, "data:#{mime.lookup(v)};base64,#{new Buffer(data).toString('base64')}")
          )
    
    async.series(matchHash, (err, resp)->
      return cb(err, null) if err
      
      for own k,v of resp
        r = new RegExp(escapeRegExp(k), 'gm')
        str = str.replace(r, v)

      cb(err, str)
    )    

  else

    cb(false, str)


base.transform = (file)->
  src = ""
  
  through((buffer)->
    src += buffer
  , ()->
    
    base.direct(src, file, (err, resp)=>
      if err
        return @emit('error', err)

      @queue(resp)
      @queue(null)
    )
  )


module.exports = base
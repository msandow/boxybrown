fs = require('fs')

module.exports = (path, tokens, cb) ->

  fs.readFile(path, {encoding: 'utf-8'}, (err, data)=>
      cb(err, null) if err
      
      while /#\{(.*?)\}/gm.test(data)
        finds = arrayUnique(data.match(/#\{(.*?)\}/gm))
        replaces = finds.map((f)=>
          str = f.substring(2, f.length-1)
          return if tokens[str] isnt undefined then tokens[str] else ''
        )

        for find, idx in finds
          data = data.replace(new RegExp(escapeRegExp(find),'gm'), replaces[idx])
      
      cb(null, data)
    )
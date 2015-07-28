crypto = require('crypto')

module.exports = class StringFile
  constructor: (@contentType = 'application/octet') ->
    @contents = ''
    @etag = ''
    @
  
  reset: () ->
    @contents = ''
    @etag = ''
    @
  
  append: (str = '') ->
    @contents += str
    @etag = crypto.createHash('md5').update(@contents).digest('hex')
    @
  
  set: (str = '') ->
    @contents = str
    @etag = crypto.createHash('md5').update(@contents).digest('hex')
    @
    
  indexOf: ()->
    @contents.indexOf.apply(@contents, arguments)
    
  substring: ()->
    @contents.substring.apply(@contents, arguments)
    
  lastIndexOf: ()->
    @contents.lastIndexOf.apply(@contents, arguments)
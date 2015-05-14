module.exports =
  arrayUnique: (arr = []) ->
    retArr = []
    hash = {}

    for item in arr
      if ['number', 'string'].indexOf(typeof item) > -1
        if hash[item] is undefined
          retArr.push(item)
          hash[item] = true
      else
        retArr.push(item)

    retArr
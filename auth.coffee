crypto = require('crypto')

class this.Auth
  constructor: (@secret) ->

  check: (room, sig, fn) ->
    if !@secret?
      fn(null, true)
      return
    if @secret? && !sig?
      fn("Must provide key", false)
      return

    x = @_splitSig(sig)
    if !x?
      fn("Bad sig", false)
      return
    hash = x[0]
    ts = x[1]

    ts = parseInt(ts)
    if ts == NaN
      fn("Bad time", false)
      return
    if ts < (new Date).getTime()
      fn("Time has passed", false)
      return
    toHash = room + ts + @secret
    
    checkHash = @_genKey(room, ts)
    
    err = null
    res = true
    
    if checkHash != hash
      err = "Bad key"
      res = false
    fn(err, res)
    
  _genKey: (room, ts) ->
    shasum = crypto.createHash('sha256')
    shasum.update(room + ts + @secret)
    shasum.digest('hex')


  _splitSig: (sig) ->
    m = sig.match(/^([^:]+):(.+)?/)
    return if m? then  [m[1], m[2]] else null
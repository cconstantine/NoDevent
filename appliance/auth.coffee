bcrypt = require('bcrypt')

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
    checkHash = room + ts + @secret
    bcrypt.compare checkHash, hash, (err, res) ->
      if !err? && res == false
        err = "Bad key"
      fn(err, res)

    
  _genKey: (room, ts, fn) ->
    toHash = room + ts + @secret
    bcrypt.hash toHash, 8, fn


  _splitSig: (sig) ->
    m = sig.match(/^([^:]+):(.+)?/)
    return if m? then  [m[1], m[2]] else null
room = null
NoDevent.ready ->
  console.log 'hi'

  NoDevent.socket.on 'connect', ->
      console.log('connected')

  room = NoDevent.join 'theroom', (success) ->
    if success
      console.log('joined: theroom')

  room.on 'ping', (data) ->
    console.log "1: " + data

  room.on 'ping', (data) ->
    console.log "2: " + data



NoDevent.on 'connect', ->
  console.log('nodevent connected')

room = NoDevent.join 'theroom', (err) ->
  if !err?
    console.log('joined: theroom')

room.on 'ping', (data) ->
  console.log "1: " + data

room.on 'ping', (data) ->
  console.log "2: " + data



NoDevent.control.on 'connect', ->
  console.log('nodevent connected')

room = NoDevent.join 'theroom', (success) ->
  if success
    console.log('joined: theroom')

room.on 'ping', (data) ->
  console.log "1: " + data

room.on 'ping', (data) ->
  console.log "2: " + data


window.onReady = ->
  console.log 'onReady'
  socket = io.connect('http://localhost:8080/nodevent')
  socket.on 'connect', ->
    console.log 'socket connect'


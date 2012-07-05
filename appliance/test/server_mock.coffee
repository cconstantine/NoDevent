EventEmitter = require('events').EventEmitter

class this.ServerMock extends EventEmitter
  constructor: () ->
    @rooms = {}

    @on 'join', (room, fn) ->
      @rooms[room] = true
      if fn?
        process.nextTick ->
          fn(null)

    @on 'leave', (room, fn) ->
      delete @rooms[room]
      if fn?
        process.nextTick ->
          fn(null)


    super()

  event: (room, event, message) ->
    if @rooms[room]?
      @emit('event', {room: room, event: event, message: message})
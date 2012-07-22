`if (typeof EventEmitter == 'undefined'){ EventEmitter = require('events').EventEmitter }`

class Room extends EventEmitter
  constructor: (@id, @controller) ->
    super
    @join_callbacks = []

    @inRoom = false
    @controller.on 'connect', =>
      if @inRoom
        @_doJoin()
              
  id: @id

  getKey: () ->
    @key

  setKey: (@key) ->
    @_doJoin()
    
  join: (fn) ->
    # Put in a placeholder function if not given one
    if fn?
      @once('join', fn)
    @inRoom = true
    @_doJoin()

  leave: (fn) ->
    @inRoom = false 
    if fn?
      @once('leave', fn)
      
    if @controller.socket
      @controller.socket.emit 'leave', {room : @id}, (err) =>
        @emit('leave', err)
        
  _doJoin: () ->
    obj = @
    if  @inRoom && @controller.socket?
      arg = {room : @id}
      arg.key = @key if @key?
      @controller.socket.emit 'join', arg, (err) =>
        @emit('join', err)

      
class this.NoDeventController extends EventEmitter
  constructor: () ->
    super()
    @rooms = {};
      
  down: () ->
    if @socket?
      @socket.removeAllListeners()

    for room,obj of @rooms
      obj.removeAllListeners()
    @removeAllListeners()


  setSocket: (socket) ->
    @socket = socket
    @socket.on 'connect', =>
      @emit('connect')
    if @connected()
      @emit('connect')

    @socket.on 'event', (data) =>
      @room(data.room).emit(data.event, data.message);

  connected: () ->
    @socket? && @socket.socket? && @socket.socket.connected
    
  room: (name) ->
    @rooms[name] ?= new Room(name, @);

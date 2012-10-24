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
    @rooms = {}
      
  down: () ->
    if @socket?
      @socket.removeAllListeners()

    for room, obj of @rooms
      obj.removeAllListeners()
    @removeAllListeners()


  setSocket: (socket) ->
    @socket = socket
    @socket.on 'connect', =>
      @emit('connect')
    @socket.on 'connecting', (transport_type) =>
      @emit('connecting', transport_type)
    @socket.on 'disconnect', =>
      @emit('disconnect')
    @socket.on 'connect_failed', =>
      @emit('connect_failed')
    @socket.on 'close', =>
      @emit('close')
    @socket.on 'error', =>
      @emit('error')
    @socket.on 'reconnect_failed', =>
      @emit('reconnect_failed')
    @socket.on 'reconnect', (transport_type, reconnectionAttempts) =>
      @emit('reconnect', transport_type, reconnectionAttempts)
    @socket.on 'reconnecting', (reconnectionDelay, reconnectionAttempts) =>
      @emit('reconnecting', reconnectionDelay, reconnectionAttempts)
      
    if @connected()
      @emit('connect')

    @socket.on 'event', (data) =>
      @room(data.room).emit(data.event, data.message)

  connected: () ->
    @socket? && @socket.socket? && @socket.socket.connected
    
  room: (name) ->
    @rooms[name] ?= new Room(name, @)

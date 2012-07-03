#= require head
#= require eventemitter

class Room extends EventEmitter
  constructor: (@id) ->
    super
  id: @id

class NoDevent
  constructor: () ->
    @rooms = {};
    @join_callbacks = { }
    @control = new EventEmitter

  setSocket: (socket) ->
    @socket = socket

    socket.on 'connect', () =>
      for room,callbacks of @join_callbacks
        @socket.emit 'join', {room : room}, (success) ->
          for callback in callbacks
            callback(success);

    @socket.on 'connect', =>
      @control.emit('connect')

    @socket.on 'event', (data) =>
      @room(data.room).emit(data.event, data.message);

  room: (name) ->
    @rooms[name] ?= new Room(name);

  join: (room, fn) ->
    # Put in a placeholder function if not given one
    if !fn
      fn = (success) ->
        success

    if !@join_callbacks[room]
      @join_callbacks[room] = [fn];
    else

      found = false;
      for i in @join_callbacks[room]
        callback = join_callbacks[room][i];
        found = found || (callback == fn);

      if !found
        @join_callbacks[room].push(fn);

    if @socket
      @socket.emit 'join', {room : room}, (success)->
        fn(success)

    return @room(room);


  @leave: (room, fn) ->
    delete @join_callbacks[room]
    if @socket
      @socket.emit 'leave', {room : room}, (success) ->
        fn(success);

window.NoDevent = new NoDevent()
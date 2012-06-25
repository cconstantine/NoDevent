#= require head
#= require eventemitter


window.NoDevent = {}

class Room extends EventEmitter
  constructor: (@id) ->
    super

  id: @id

window.Room = Room

NoDevent._ready = (fn) ->
  rooms = {};
  NoDevent.room = (name) ->
    rooms[name] ?= new Room(name);

  join_callbacks = { }
  NoDevent.join = (room, fn) ->
    # Put in a placeholder function if not given one
    if !fn
      fn = (success) ->
        success

    if !join_callbacks[room]
      join_callbacks[room] = [fn];
    else
      found = false;
      for i in join_callbacks[room]
        callback = join_callbacks[room][i];
        found = found || (callback == fn);

      if !found
        join_callbacks[room].push(fn);

    NoDevent.socket.emit 'join', {room : room}, (success)->
      fn(success)

    return NoDevent.room(room);


  NoDevent.leave = (room, fn) ->
    delete join_callbacks[room]
    NoDevent.socket.emit 'leave', {room : room}, (success) ->
      fn(success);


  NoDevent.socket.on 'connect', (socket) ->
    for room,callbacks of join_callbacks
      NoDevent.socket.emit 'join', {room : room}, (success) ->
        for callback in callbacks
          callback(success);

  NoDevent.socket.on 'event', (data) ->
      event = data.event;
      room = data.room;
      message = data.message;

      NoDevent.room(room).emit(event, message);

  NoDevent.is_ready = true;
  fn();

function NoDevent(room, user, opts) {            
  var s = io.connect(opts.namespace || "");
      
  var m = new EventEmitter();
  m.s = s;
  
  m.room = new EventEmitter();
    
  s.on(
    'event', 
    function (data) {
      console.log(data);
      var event = data.event;
      var message = data.message;
      
      m.emit(event, message);
    });
    
  s.on(
    'join_room', 
    function (data) {      
      console.log(data.room, data.user);
      m.room.emit('join', data);
    });

  s.emit('join', {user : user, room : room});

  return m;
}

NoDevent.ready = function(fn) {
  head.js(     
    "/socket.io/socket.io.js", "/EventEmitter.js",
    fn);
};
      
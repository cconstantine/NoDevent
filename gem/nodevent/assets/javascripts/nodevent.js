function NoDevent(opts, fn) {
  head.js(
    "/socket.io/socket.io.js", "/EventEmitter.js",
    function() {
            
      var s = io.connect(opts.url);
      
      
      var m = new EventEmitter();
      m.s = s;
      
      m.room = new EventEmitter();
      
      m.join = function(room) {
        s.emit('join', {user : opts.user, room : room});
      };
      
      m.leave = function(room) {
        s.emit('leave', {user : opts.user, room : room});
      };
      
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
      
      fn(m);
    });
}


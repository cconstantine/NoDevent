var NoDevent = {};


NoDevent.ready = function(user, opts, fn) {
  var socket_io_url = opts.base + "/socket.io/socket.io.js";
  var event_emitter_url = opts.base + "/EventEmitter.js";
  head.js(     
    socket_io_url, event_emitter_url,
    function() {
      if (NoDevent.connected) {
        fn();
        return;
      }

      function Room(name) {
        var m = new EventEmitter();
        m.name = name;

        m.users = new EventEmitter();

        return m;
      }
      var connect_url = opts.base + (opts.namespace || "");
      console.log(connect_url);
      var s = io.connect(connect_url );
      
      var rooms = {};
            
      NoDevent.room = function(name) {
        var r = rooms[name];
        if (!r) {
          r = rooms[name] = new Room(name);
        }
        return r;
      };
      
      NoDevent.join = function(room) {
        s.emit('join', {user : user, room : room});
        return NoDevent.room(room);
      };
      
      NoDevent.leave = function(room) {
        s.emit('leave', {user : opts.user, room : room});
      }; 
  
      s.on(
        'event', 
        function (data) {
          var event = data.event;
          var room = data.room;
          var message = data.message;
          
          NoDevent.room(room).emit(event, message);
        });
    
      s.on(
        'join_room', 
        function (data) {
          NoDevent.room(data.room).users.emit('join', data.user);
        });

      s.on(
        'leave_room', 
        function (data) {
          NoDevent.room(data.room).users.emit('leave', data.user);
        });
      NoDevent.connected = true;
      fn();
    }
  );
};
      
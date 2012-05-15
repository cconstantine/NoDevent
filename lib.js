var redis = require("redis");

function build_server(io, config) {
  var rooms = {};
  var client = redis.createClient(config.redis.port, config.redis.host, config.redis.options);
  
  client.subscribe(config.redis.subscribe || 'events');
  client.on(
    "message",function (channel, message) {
      var data = JSON.parse(message);
      console.log(data);
      io.in(data.room).emit("event", data);      
    });
  
  io.on(
    'connection',
    function (socket) {
      console.log("Connected");
      socket.on('join',
                function(data) {
                  console.log("join", data);
                  socket.user = JSON.stringify(data.user);
                  if (!rooms[data.room])
                    rooms[data.room] = {};
                  rooms[data.room][socket.user] = true;

                  socket.join(data.room);

                  socket.in(data.room).emit(
                    "room_members", {room : data.room,
                                     members : Object.keys(rooms[data.room])});

                  io.in(data.room).emit(
                    "join_room",
                    { room :data.room,
                      user: JSON.parse(socket.user)});
                });
      socket.on('leave',
                function(data) {
                  io.in(data.room).emit("leave_room", data.room, socket.user);
                  delete rooms[data.room][socket.user];
                  if (Object.keys(rooms[data.room]).length == 0)
                    delete rooms[data.room];
                  socket.leave(data);
                });
    });
  return io;
}

module.exports = build_server;
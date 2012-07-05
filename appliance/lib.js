var redis = require("redis");

function build_server(io, config) {
  var rooms = {};

  var client = redis.createClient(config.redis.port, config.redis.host, config.redis.options);
  
  client.subscribe(config.redis.subscribe || 'events');
  client.on(
    "message",function (channel, message) {
      var data = JSON.parse(message);
      io.in(data.room).emit("event", data);      
    });
  
  io.on(
    'connection',
    function (socket) {
      socket.on('join',
                function(data, fn) {
                  socket.join(data.room);
                  if (fn)
                    fn(null);
                });
      socket.on('leave',
                function(data, fn) {
                  socket.leave(data);
                  if (fn)
                    fn(null);
                });
    });
  return io;
}

module.exports = build_server;
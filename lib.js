var redis = require("redis");

function build_server(io, config) {
  var client = redis.createClient(config.redis.port, config.redis.host, config.redis.options);
  
  client.subscribe(config.redis.subscribe || 'events');
  client.on(
    "message",function (channel, message) {
      var data = JSON.parse(message);
      console.log(config.namespace, data);
      io.in(data.room).emit(data.event, data.message);      
    });
  
  io.on(
    'connection',
    function (socket) {
      //
      socket.on('join',
                function(data) {
                  console.log("join: " + data);
                  socket.join(data);
                });
      socket.on('leave',
                function(data) {
                  socket.leave(data);
                });
    });
  return io;
}

module.exports = build_server;
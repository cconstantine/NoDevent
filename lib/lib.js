require('coffee-script')
var redis = require("redis");
var Auth = require("./auth.coffee").Auth

function build_server(io, namespace, config) {
  var rooms = {};
  var secret = config.secret;
  var client = redis.createClient(config.redis.port, config.redis.host, config.redis.options);
  var auther = new Auth(secret)

  client.subscribe(namespace);
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
                  auther.check(data.room, data.key, function(err, res) {
			              if (res) {
                      socket.join(data.room);
                    }
			              fn(err, res);
                  });
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
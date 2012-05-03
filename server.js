
var net     = require('net');
var express = require('express');

var fs = require('fs');
function build(app) {
  
  app.configure(function () {
                  app.use(express.static(__dirname + '/public'));
                  app.use(express.cookieParser());
                  app.use(express.bodyParser());
                  app.use(app.router);
                }); 
  
  app.get('/test',
          function(req, res) {
            console.log("GET: " + req.url); 
            var s = new Buffer(req.cookies._kairos_session_.split("--")[0], 'base64').toString('ascii');
            console.log(s);
            res.json({var: s});
          });
  
  var io = require('socket.io').listen(app);
  
  var redis = require("redis"),
  client = redis.createClient(),
  publisher = redis.createClient();
  
  client.subscribe("events");
  client.on(
    "message",
    function(channel, message) {
      var data = JSON.parse(message);
      console.log(data);
      io.sockets.in(data.room).emit(data.event, data.message);
    });

  io.sockets.on(
    'connection',
    function (socket) {
      //
      socket.on('join',
                function(data) {
                  socket.join(data);
               });
      socket.on('leave',
                function(data) {
                  socket.leave(data);
               });
      socket.on(
        'clicky',
        function(data) {
          publisher.publish("events",
                            JSON.stringify({room : 'events',
                                            event: "click",
                                            message : "clicky-redis"}));
        });
    });
  

  return app;
}  

var app     = express.createServer();
build(app).listen(80);
app.listen(80);


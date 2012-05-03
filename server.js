
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
      console.log(channel, message);
      data = JSON.parse(message);
      console.log(data.channel, data.message);
      io.sockets.in('chatty').emit(data.channel, data.message);
      io.sockets.in('batty').emit(data.channel, data.message);

    });

  io.sockets.on(
    'connection',
    function (socket) {
      //
      socket.on('join',
                function(data) {
                  socket.join(data);
               });
      socket.on(
        'clicky',
        function(data) {
          console.log('clicky', data);
          publisher.publish("events",
                            JSON.stringify({channel : 'events',
                                            message : "clicky-redis"}));
        });
    });
  

  return app;
}  

var app     = express.createServer();
build(app).listen(80);
app.listen(80);


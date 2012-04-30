
var net     = require('net');
var express = require('express');

var app     = express.createServer();

var fs = require('fs');
    
app.configure(function () {
                app.use(express.static(__dirname + '/public'));
                app.use(express.cookieParser());
                app.use(express.bodyParser());
                app.use(app.router);
              }); 

app.get('/',
        function(req, res) {
          console.log("GET: " + req.url); 
          var s = new Buffer(req.cookies._peakpickup_session.split("--")[0], 'base64').toString('ascii');
          console.log(s);
          res.end('var: ');
        });

var io = require('socket.io').listen(app);

var redis = require("redis"),
    client = redis.createClient();
    publisher = redis.createClient();

client.subscribe("events");
io.sockets.on(
  'connection',
  function (socket) {
    socket.join('clicky'); 
    socket.on(
      'clicky',
      function(data) {
        console.log('clicky', data);
        publisher.publish("events", "clicky-redis");
      });
  });

client.on(
  "message",
  function(channel, message) {
    io.sockets.emit("events", 'redis click');
    console.log(channel, message);
});

app.listen(80);

setInterval(
  function() {
    io.sockets.emit("events", 'fake');
              
}, 1000);

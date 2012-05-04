
var net     = require('net');
var express = require('express');

var fs = require('fs');
function build_server(app, configs) {
  
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
  io.set('log level', 0);
  io.enable('browser client minification');  // send minified client
  io.enable('browser client etag');          // apply etag caching logic based on version number
  io.enable('browser client gzip');          // gzip the file

  
  configs.forEach(function(config) {
//    var config = configs[i];
    console.log(config);

    var redis = require("redis");
    var client = redis.createClient(config.redis.port, config.redis.host, config.redis.options);
    var publisher = redis.createClient(config.redis.port, config.redis.host, config.redis.options);
    
    function sendEvent(channel, message) {
        var data = JSON.parse(message);
        console.log(config.namespace, data);
        io.of(config.namespace).in(data.room).emit(data.event, data.message);      
    }
    client.subscribe("events");
    client.on(
      "message",
      sendEvent);/*
      function(channel, message) {
        var data = JSON.parse(message);
        console.log(configs[i].namespace, data);
        io.of(config.namespace).in(data.room).emit(data.event, data.message);
      });*/
    
    io.of(config.namespace).on(
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
        
        socket.on(
          'clicky',
          function(data) {
            publisher.publish("events",
                              JSON.stringify({room : 'events',
                                              event: "click",
                                              message : "clicky-redis"}));
          });
      });
    
  });

  return app;
}  


build_server(express.createServer(), [
               {namespace : '/development',redis : {port :6379 ,host : 'localhost'}}
               ,{namespace : 'staging',    redis : {port :6379 ,host : 'localhost'}}
               ,{namespace : '/production', redis : {port :6379 ,host : 'jobs1'}}
             ]).listen(80);  

try {
//  var prod = build_server(express.createServer(), '/production', {port :6379 ,host : 'jobs1'}).listen(80);  
} catch (x) {

}


process.on('uncaughtException', function (err) {
  console.log('Caught exception: ' + err);
});



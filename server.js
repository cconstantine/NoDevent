var nodevent = require('./lib.js');
var express = require('express');
var app = express.createServer();

app.configure(function () {
                  app.use(express.static(__dirname + '/public'));
                  app.use(express.cookieParser());
                  app.use(express.bodyParser());
                  app.use(app.router);
                }); 
  
  
var config = {
  redis : {port :6379 ,host : 'localhost'},
  namespace: '/dev'
};

if (process.argv[2]) {
  var fs = require('fs');
  config = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
}

var io = require('socket.io').listen(app);//config.port || 80);
//io.set('log level', 0);
io.enable('browser client minification');  // send minified client
io.enable('browser client etag');          // apply etag caching logic based on version number
io.enable('browser client gzip');          // gzip the file


process.on('uncaughtException', function (err) {
  console.log('Caught exception: ' + err);
});

console.log(config);
nodevent(io.of(config.namespace),config);
app.listen(80);
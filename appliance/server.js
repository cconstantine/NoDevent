var nodevent = require('./lib.js');
var express = require('express');
var app = express.createServer();
require('ejs');

app.set('view engine', 'ejs');

app.configure(function () {
                app.use(express.static(__dirname + '/public'));
                app.use(express.cookieParser());
                app.use(express.bodyParser());
                app.register('ejs', require('ejs'));
                app.use(app.router);
              }); 

app.get('/nodevent.js', function(req, res){
          console.log(req.query);
          res.contentType('js');
          
          res.render('nodevent', { opts : req.query});
        });

var config = {
  redis : {port :6379 ,host : 'localhost'},
  namespace: ''
};

if (process.argv[2]) {
  var fs = require('fs');
  config = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
}

var io = require('socket.io').listen(app);
//io.set('log level', 0);
io.enable('browser client minification');  // send minified client
io.enable('browser client etag');          // apply etag caching logic based on version number
io.enable('browser client gzip');          // gzip the file

/*
process.on('uncaughtException', function (err) {
  console.log('Caught exception: ' + err);
});
*/

console.log(config);
nodevent(io.of(config.namespace),config);
app.listen(8080);
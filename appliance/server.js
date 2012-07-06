var nodevent = require('./lib.js');
var express = require('express');
var Snockets = require('snockets');
var snocket = new Snockets();

require('ejs');


var config = {
  port: 8080, 
  "/nodevent" : {
    redis : {port :6379 ,host : 'localhost'}
  }
};

if (process.argv[2]) {
  var fs = require('fs');
  config = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
}


var app = module.exports = express.createServer();
app.set('view engine', 'ejs');
app.configure(function () {
                app.use(express.static(__dirname + '/public'));
                app.use(express.cookieParser());
                app.use(express.bodyParser());
                app.use(require('connect-assets')());
                app.set('view engine', 'jade');
                app.set('view options', { layout: false });
                app.register('ejs', require('ejs'));
                
                app.use(app.router);
              }); 

app.get('/', function(req, res) {
          res.render('index');
        });
app.get('/api/:namespace', function(req, res){
          res.contentType('js');
          
          var host = req.connection.encrypted ?
            "https://" : "http://" +
            req.headers.host;

          snocket.getConcatenation('assets/js/nodevent_asset.coffee',
                                   {minify: false},
                                   function(err, js) {
                                     if (err)
                                       throw err;
                                     res.render('nodevent.ejs', { deps : js,
                                                                  opts : 
                                                                  {namespace : req.params.namespace,
                                                                   host : host}});
                                   });
        });

var io = require('socket.io').listen(app, {'log level' : 0});
io.enable('browser client minification');  // send minified client
io.enable('browser client etag');          // apply etag caching logic based on version number
io.enable('browser client gzip');          // gzip the file


for(var namespace in config) {
  if (namespace[0] == '/') {
    var ns = io.of(namespace);
    nodevent(ns,config[namespace]);
  }
}

// Are we running as a server?
if (!module.parent) {
  process.on('uncaughtException', function (err) {
               console.log('Caught exception: ' + err);
             });

  app.listen(config.port);
  if (process.send)
    process.send("ready");
}

var nodevent = require('./lib.js');

var config = {
  redis : {port :6379 ,host : 'localhost'},
  namespace: '/'
};

if (process.argv[2]) {
  var fs = require('fs');
  config = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
}

var io = require('socket.io').listen(config.port || 80);
io.set('log level', 0);
io.enable('browser client minification');  // send minified client
io.enable('browser client etag');          // apply etag caching logic based on version number
io.enable('browser client gzip');          // gzip the file


process.on('uncaughtException', function (err) {
  console.log('Caught exception: ' + err);
});

nodevent(io.of(config.namespace),config);
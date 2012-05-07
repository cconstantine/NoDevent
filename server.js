var nodevent = require('./lib.js');

var io = require('socket.io').listen(80);
io.set('log level', 0);
io.enable('browser client minification');  // send minified client
io.enable('browser client etag');          // apply etag caching logic based on version number
io.enable('browser client gzip');          // gzip the file


process.on('uncaughtException', function (err) {
  console.log('Caught exception: ' + err);
});

nodevent(io.of('/development'),{redis : {port :6379 ,host : 'localhost'}});
nodevent(io.of('/staging'),    {redis : {port :6379 ,host : 'application_test'}});
nodevent(io.of('/production'), {redis : {port :6379 ,host : 'jobs1'}});




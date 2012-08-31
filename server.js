require('coffee-script')

var cm = new (require('./lib/appliance').Appliance)(process.argv)

process.on('uncaughtException', function (err) {
  console.log('Caught exception: ' + err);
});

if (process.send)
  process.send("ready");




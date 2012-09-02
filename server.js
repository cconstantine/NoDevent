require('coffee-script')
Appliance = require('./lib/appliance').Appliance
var cm = new Appliance(process.argv)

process.on('uncaughtException', function (err) {
  console.log('Caught exception: ' + err);
});

if (process.send)
  process.send("ready");




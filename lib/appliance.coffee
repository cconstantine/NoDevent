require('coffee-script')

path = require('path')
fs   = require('fs');
express = require('express');
Snockets = require('snockets');
snocket = new Snockets();
Namespaces = require('./namespaces').Namespaces
    
class this.Appliance
  constructor: (args) ->
    @activeNamespaces = {}
    if args[2]
      @config_filename = args[2]
    else if  fs.existsSync('/etc/nodevent.json')
      @config_filename = '/etc/nodevent.json'
    else 
      @config_filename = path.join(__dirname, "../config.json")
    @config = JSON.parse(fs.readFileSync(@config_filename, "utf8"))
        
    if @config.ssl?
      @app = express.createServer
        key: fs.readFileSync(@config.ssl.key).toString() 
        cert:fs.readFileSync(@config.ssl.cert).toString()
    else
      @app = express.createServer()
      
    @io = require('socket.io').listen(@app, {'log level' : 0})
    @io.enable('browser client minification')
    @io.enable('browser client etag')
    #@io.enable('browser client gzip')
    @app.set('view engine', 'ejs');
    @app.configure () =>
      @app.use(express.static(__dirname + '/public'));
      @app.use(express.cookieParser());
      @app.use(express.bodyParser());
      @app.use(require('connect-assets')());
      @app.set('view engine', 'jade');
      @app.set('view options', { layout: false });
      @app.register('ejs', require('ejs'));

      @app.use(@app.router);

    @namespaces = new Namespaces(@io)
    for k,v of @config
      if k[0] == '/'
        @namespaces.add(k, v)

    @app.get '/api/:namespace', (req, res) =>
      res.contentType('js');

      host = if req.connection.encrypted then "https://" else "http://"
      host += req.headers.host
      namespace = '/' + req.params.namespace

      snocket.getConcatenation(
        'assets/js/nodevent_asset.coffee',
        {minify: false},
        (err, js) =>
          if (err)
            res.statusCode = 500
            res.end("");
            throw err
          else if @namespaces.exists(namespace)
            res.render('nodevent.ejs',
              deps : js,
              opts :
                namespace : namespace.slice(1),
                host : host)
          else
            res.statusCode = 404
            res.end("Namespace #{req.params.namespace} not found.");

      )
    @listen()

  listen: () ->
    @app.listen(@config.port);

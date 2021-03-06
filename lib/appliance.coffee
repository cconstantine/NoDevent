require('coffee-script')

path = require('path')
fs   = require('fs')
express = require('express')
Snockets = require('snockets')
snocket = new Snockets()
Namespaces = require('./namespaces').Namespaces
    
https = require 'https'
http = require 'http'

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
 
    @app = express()
      
    @app.set('view engine', 'ejs')
    @app.configure () =>
      @app.use(express.static(__dirname + '/public'))
      @app.use(express.cookieParser())
      @app.use(express.bodyParser())
      @app.use(require('connect-assets')())
      @app.set('view engine', 'jade')
      @app.set('view options', { layout: false })
      @app.set('views', path.join(__dirname, "../views"))
      @app.engine('ejs', require('ejs').renderFile)
      @app.use(@app.router)
      
    @app.get '/api/:namespace', (req, res) =>
      res.contentType('js')

      host = if req.connection.encrypted then "https://" else "http://"
      host += req.headers.host
      namespace = '/' + req.params.namespace

      snocket.getConcatenation(
        path.join(__dirname, "../assets/js/nodevent_asset.coffee"),
        {minify: false},
        (err, js) =>
          if (err)
            res.statusCode = 500
            res.end("")
            throw err
          else if @namespaces.exists(namespace)
            res.render('nodevent.ejs',
              deps : js,
              opts :
                namespace : namespace.slice(1),
                host : host)
          else
            res.statusCode = 404
            res.end("Namespace #{req.params.namespace} not found.")

      )
    @listen()

  listen: () ->
    @config.listen ||= []
    if @config.port
      server_config = {port: @config.port}
      if @config.ssl?
        server_config.ssl = @config.ssl
      @config.listen.push(server_config)
    
    io_list = for c in @config.listen
      if c.ssl?
        opts =
          key:  fs.readFileSync(c.ssl.key).toString()
          cert: fs.readFileSync(c.ssl.cert).toString()
        srv = https.createServer(opts, @app).listen(c.port)
      else
        srv = http.createServer(@app).listen(c.port)
        
      io = require('socket.io').listen(srv, {'log level' : 0})
      io.enable('browser client minification')
      io.enable('browser client etag')
      
    @namespaces = new Namespaces(io_list)
    for k,v of @config
      if k[0] == '/'
        @namespaces.add(k, v)
          

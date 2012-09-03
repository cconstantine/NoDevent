require('coffee-script')
redis = require("redis");
Auth = require("./auth.coffee").Auth

class this.Namespaces
  constructor: (@io) ->
    @namespaces = {}
    
  add: (namespace, config) ->
    if @namespaces[namespace]?
      return
      
    ns = 
      secret: config.secret
      client: redis.createClient(config.redis.port, config.redis.host, config.redis.options)
      auther: new Auth(config.secret)
      io:     @io.of(namespace)

    ns.client.subscribe(namespace)
    
    ns.client.on "message", (channel, message) =>
      data = JSON.parse(message);
      ns.io.in(data.room).emit("event", data);      
   
  
    ns.io.on 'connection', (socket) =>
      socket.on 'join', (data, fn) =>
        ns.auther.check data.room, data.key, (err, res) =>
          if (res) 
            socket.join(data.room);
          fn(err, res)
          
      socket.on 'leave', (data, fn) =>
        socket.leave(data);
        if (fn)
          fn(null)

    @namespaces[namespace] = ns
    
  remove: (name) ->
    return unless @exists(name)

    ns = @namespaces[name]
    ns.client.unsubscribe(name)
    
    ns.client.removeAllListeners()
    ns.io.removeAllListeners()
    
    delete @namespaces[name]
    
  exists: (name) ->
    @namespaces[name]?

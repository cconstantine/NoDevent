require('coffee-script')
redis = require("redis");
Auth = require("./auth.coffee").Auth


class this.Namespaces
  constructor: (@io) ->
    @namespaces = {}
    
  add: (namespace, config) ->
    @namespaces[namespace] = true
    io = @io.of(namespace)
    secret = config.secret
    client = redis.createClient(config.redis.port, config.redis.host, config.redis.options)
    auther = new Auth(secret)

    client.subscribe(namespace)
    
    client.on "message", (channel, message) =>
      data = JSON.parse(message);
      io.in(data.room).emit("event", data);      
   
  
    io.on 'connection', (socket) =>
      socket.on 'join', (data, fn) =>
        auther.check data.room, data.key, (err, res) =>
          if (res) 
            socket.join(data.room);
          fn(err, res)
          
      socket.on 'leave', (data, fn) =>
        socket.leave(data);
        if (fn)
          fn(null)
                
  exists: (name) ->
    @namespaces[name]?

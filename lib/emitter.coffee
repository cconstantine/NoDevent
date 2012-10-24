
redis = require("redis")

class this.Emitter
  constructor: (@namespace, config) ->
    @client = redis.createClient(config.redis.port, config.redis.host, config.redis.options)

  emit: (room, event, message) ->
    @client.publish(@namespace, JSON.stringify({event: event, room: room, message: message}))

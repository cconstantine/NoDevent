
redis = require("redis")

class Emitter
  constructor: (config) ->
    @client = redis.createClient(config.redis.port, config.redis.host, config.redis.options);

  emit: (room, event, message) ->
    @client.publish('events', JSON.stringify({event: event, room: room, message: message}))

module.exports = Emitter
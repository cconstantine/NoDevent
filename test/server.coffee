http               = require('http')

class this.Server
  constructor: () ->
    @spawn = require('child_process').fork
    process.on 'SIGINT', =>
      @stop()

    process.on 'exit', =>
      @stop()

  start: (fn)->
    if @child?
      fn()
    else
      @child = @spawn('server.js', ['./test/config.json'])
      @child.once 'message', (m) =>
        if m == 'ready'
          http.get "http://localhost:9876/api/nodevent", ->
            http.get "http://localhost:9876/api/protected", ->
              fn()
      @child.once 'exit', =>
        @child = null;


  stop: (fn) ->
    if !@child?
      fn() if fn?
      return

    @child.once 'exit', ->
      fn() if fn?
    @child.kill('SIGTERM')

  restart: (fn) ->
    @stop =>
      @start fn


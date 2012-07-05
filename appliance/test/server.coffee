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
      @child = @spawn('server.js')
      @child.once 'message', (m) =>
        if m == 'ready'
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


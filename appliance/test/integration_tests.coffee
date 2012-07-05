NoDeventController = require('../assets/js/nodevent.coffee').NoDeventController
Emitter            = require("../emitter.coffee")
io                 = require('socket.io-client');

emitter = new Emitter({redis: {}});

websocket = () ->
  ws = io.connect('http://localhost:8080/nodevent', {'force new connection': true})
  return ws

class Server
  constructor: () ->
    @spawn = require('child_process').fork
    process.on 'SIGINT', ->
      server.stop()

    process.on 'exit', ->
      server.stop()

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


server = new Server
spawn = require('child_process').spawn

describe 'self testing', ->
  it "causes disconnects", (done)->
    server.start ->
      ws = websocket()
      ws.on 'disconnect', ->
        done()
      ws.on 'connect', ->
        server.stop()

describe 'NoDevent', ->
  beforeEach ()->
    @NoDevent = new NoDeventController

  afterEach ()->
    @NoDevent.down()
    @NoDevent.removeAllListeners()

  describe "#on", ->
    it "should notify on connect", (done) ->
      server.start =>
        @NoDevent.on 'connect', ->
          server.stop(done)
        @NoDevent.setSocket(websocket())

  describe 'with a connection', ->
    before (done)->
      server.start done
    after (done)->
      server.stop(done)

    beforeEach (done)->
      @NoDevent.setSocket(websocket())
      @NoDevent.on 'connect', done

    describe '#join()', ->
      it 'should allow us to join a room', (done)->
        @NoDevent.join 'theroom', done

      it 'should receive messages after joining', (done)->
        room = this.NoDevent.join 'theroom'
        room.once 'theevent', (data) ->
          data.should.equal('thedata')
          done()
        emitter.emit('theroom', 'theevent', 'thedata')

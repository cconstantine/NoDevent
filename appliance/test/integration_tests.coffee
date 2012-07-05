NoDeventController = require('../assets/js/nodevent.coffee').NoDeventController
Emitter            = require("../emitter.coffee")
io                 = require('socket.io-client');
Server             = require('./server.coffee').Server

emitter = new Emitter({redis: {}});

#process.on 'uncaughtException', (err) ->
#  console.log('Caught exception: ' + err);

websocket = () ->
  io.connect('http://localhost:8080/nodevent', {'force new connection': true})

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

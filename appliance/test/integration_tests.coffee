NoDeventController = require('../assets/js/nodevent.coffee').NoDeventController
Emitter            = require("../emitter.coffee")
io                 = require('socket.io-client');
Server             = require('./server.coffee').Server
should             = require('should')
crypto             = require('crypto')

emitter = new Emitter({redis: {}});

#process.on 'uncaughtException', (err) ->
#  console.log('Caught exception: ' + err);

websocket = () ->
  io.connect('http://localhost:9876/nodevent', {'force new connection': true})

websocket_protected = () ->
  io.connect('http://localhost:9876/protected', {'force new connection': true})

server = new Server
spawn = require('child_process').spawn

genKey = (room, ts, fn) ->
  toHash = room + ts + 'asdf'
  shasum = crypto.createHash('sha256')
  shasum.update(toHash)
  shasum.digest('hex') + ":" + ts
        
describe 'ServerProcess', ->
  it "causes disconnects", (done)->
    server.start ->
      ws = websocket()
      ws.once 'disconnect', ->
        done()
      ws.once 'connect', ->
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

  describe 'with a server', ->
    before (done)->
      server.start done
    after (done)->
      server.stop(done)

    describe 'with a normal connection', ->
      beforeEach (done)->
        @NoDevent.setSocket(websocket())
        @NoDevent.on 'connect', done
        @room = @NoDevent.room('theroom')

      describe '#join()', ->
        it 'should allow us to join a room', (done)->
          @room.join done

        it 'should receive messages after joining', (done)->
          @room.join()
          @room.once 'theevent', (data) ->
            data.should.equal('thedata')
            done()
          emitter.emit('theroom', 'theevent', 'thedata')

    describe 'with a protected connection', ->
      beforeEach (done)->
        @NoDevent.setSocket(websocket_protected())
        @NoDevent.on 'connect', done
        @room = @NoDevent.room('theroom')

      describe '#join()', ->
        it 'should not allow us to join a room raw', (done)->
          @room.join (err) ->
            should.exist(err)
            done()

        it 'should not allow us to join a room with a bad key', (done)->
          @room.setKey('badkey')
          @room.join (err) ->
            should.exist(err)
            done()

        it 'should not allow us to join a room with a key in the past', (done)->
          ts = (new Date()).getTime() - 60*1000
          @room.setKey(genKey('theroom', ts))
          @room.join (err) ->
            should.exist(err)
            done()
                        
        it 'should receive messages after joining', (done)->
          ts = (new Date()).getTime() + 60*1000
          @room.setKey(genKey('theroom', ts))
          @room.join (err) ->
            should.not.exist(err)
            emitter.emit('theroom', 'theevent', 'thedata')
          @room.once 'theevent', (data) ->                                
            data.should.equal('thedata')
            done()

NoDeventController = require('../assets/js/nodevent.coffee').NoDeventController
Emitter            = require("../emitter.coffee")
io                 = require('socket.io-client');
app                = require('../server.js')

emitter = new Emitter({redis: {}});

describe 'NoDevent', ->
  before (done)->
    app.listen(9876, done)

  beforeEach ()->
    this.NoDevent = new NoDeventController

  describe "#on", ->
    it "should notify on connect", (done) ->
      this.socket = io.connect('http://localhost:9876/nodevent')
      this.NoDevent.on 'connect', done
      this.NoDevent.setSocket(this.socket)

  describe 'with a connection', ->
    beforeEach ()->
      this.socket = io.connect('http://localhost:9876/nodevent')
      this.NoDevent.setSocket(this.socket)


    describe '#join()', ->
      it 'should allow us to join a room', (done)->
        this.NoDevent.join 'theroom', done

      it 'should receive messages after joining', (done)->
        room = this.NoDevent.join 'theroom'
        room.once 'theevent', (data) ->
          data.should.equal('thedata')
          done()

        emitter.emit('theroom', 'theevent', 'thedata')


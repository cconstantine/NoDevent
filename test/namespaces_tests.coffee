Namespaces         = require('../lib/namespaces').Namespaces
socketio           = require('socket.io')
should             = require('should')
io                 = require('socket.io-client');
Emitter            = require('../lib/emitter')

config =
  redis:
    port: 6379
    host : "localhost"
  
describe 'Namespaces', ->
  beforeEach (done)->
    @io = socketio.listen 9786,{'log level' : 0},  =>
      @namespaces = new Namespaces(@io)
      done()
      
  afterEach ->
    @io.server.close()
    
  describe "with an added namespace", () ->
    beforeEach ->
      @namespaces.add('/nodevent', config)
      
    it "exists", ()->
      @namespaces.exists('/nodevent').should.equal(true)
   
    describe "connected", () ->
      beforeEach (done) ->
        @emitter = new Emitter('/nodevent', config)
        @connection = io.connect('http://localhost:9786/nodevent', {'force new connection': true})
        @connection.on 'connect', done

      describe "in the_room", () ->
        beforeEach (done)->
          @connection.emit 'join', {room: 'the_room'}, (err) ->
          done()

        it "emits", (done) ->
          @connection.on 'event', -> done()
          @emitter.emit('the_room', 'the_event', 'the_message')
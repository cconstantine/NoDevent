NoDeventController = require('../assets/js/nodevent.coffee').NoDeventController
ServerMock = require('./server_mock.coffee').ServerMock

describe 'ServerMock', ->
  it "sends events", (done)->
    sm = new ServerMock
    sm.rooms['theroom'] = true
    sm.on 'event', (data) ->
      data.event.should.equal('theevent')
      data.room.should.equal('theroom')
      data.message.should.equal('themessage')
      done()

    sm.event('theroom', 'theevent', 'themessage')


describe 'NoDeventController', ->
  beforeEach ->
    @NoDevent = new NoDeventController
    @server = new ServerMock

  describe "#join", ->
    describe "without an initial connection", ->
      it "joins a room", (done)->
        @NoDevent.room('theroom').join done

        @NoDevent.setSocket(@server)
        @server.emit('connect')

    describe "with an initial connection", ->
      beforeEach ->
        @NoDevent.setSocket(@server)

      it "joins a room", (done)->
        @NoDevent.room( 'theroom').join done

      it "joins a room twice", (done)->
        count = 0
        @NoDevent.room('theroom').on 'join', ->
          count++
          if count >= 2
            done()
        @NoDevent.room('theroom').join()
        @server.emit 'connect'




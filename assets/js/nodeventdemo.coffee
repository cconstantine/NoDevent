#= require jquery-1.7.2.min

$ ->
  NoDevent.on 'connect', ->
    $('#container').append("<div>connected</div>")

  room = NoDevent.join 'theroom', (err) ->
    if !err?
      $('#container').append("<div>joined: theroom</div>")
    else
      $('#container').append("<div>failed to joined: theroom (" + err + ")</div>")


  room.on 'ping', (data) ->
    $('#container').append("<div>ping: " + JSON.stringify(data) + "</div>")


var events = null;
NoDevent.ready(
  function() {
    events = new NoDevent("theroom", {name : 'bob'}, {namespace : '/dev'}); 
    
    events.room.on('join', function(data) {
                     var room = data.room;
                     var user = data.user;
                     console.log("joining ",  room);
                     console.log(user);
                   });
        
    events.on('theevent',
              function(data) {
                $(".event").html(data);
              });
  });

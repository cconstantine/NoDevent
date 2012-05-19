$(function () {
    NoDevent.ready(
      {name : 'bob'},
      function() {
        var theroom = NoDevent.join('theroom');
        console.log(theroom);
        theroom.on('theevent',
                   function(data) {
                     $(".event").html(data);
                   });
        
        theroom.users.on(
          'join',
          function(user) {
            console.log("joining ",  theroom.name, user.name);
          });
        
      });
  });
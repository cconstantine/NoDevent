$(function () {
    NoDevent.ready(
      {name : 'bob'}, {namespace : '/dev', base : 'http://localhost:80'},
      function() {
        var theroom = NoDevent.join('theroom');
        
        theroom.on('theevent',
                   function(data) {
                     $(".event").html(data);
                   });
        
        theroom.users.on(
          'join',
          function(user) {
            console.log("joining ",  theroom.name, user.name);
          });
        
        var otherroom = NoDevent.join('otherroom');
        otherroom.on('theevent',
                     function(data) {
                       $(".event").html(data);
                     });
        
        otherroom.users.on(
          'join',
          function(user) {
            console.log("joining ",  otherroom.name, user.name);
          });
        
        
      });
  });
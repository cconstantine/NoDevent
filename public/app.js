var io = io.connect('/');

io.on(
  'events', 
  function (data) {
    console.log(data);
    $('.logs').after('<p>' + data + '</p>');
  });


io.on(
  'connect', function(socket) {
    $('.logs').after('<p>Connected</p>');    
  });

$(function() {
    $("#clicky").click(
      function() {
        io.emit("clicky", "click");
      });
  });

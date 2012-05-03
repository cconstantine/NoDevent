var io = io.connect('/');

io.on(
  'click', 
  function (data) {
    console.log(data);
    $('.logs').after('<p>' + data + '</p>');
  });


io.on(
  'connect', function(socket) {
    $('.logs').after('<p>Connected</p>');
    io.emit('join', 'events');
  });

$(function() {
    $("#clicky").click(
      function() {
        io.emit("clicky", "click");
      });
  });

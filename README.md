NoDevent
=======
A bridge for posting server events to a redis pubsub and having it go out to browsers. 

This is useful for notifying browser js clients about events happening on the server such as private messages, new discussion posts, or interesting resque jobs.

See a demo at http://nodevent.com

Quick* Start (Rails)
-----------
1) Install Node.js

2) Install and start NoDevent with npm:

    npm install nodevent
    npm start nodevent

3) Add the following to the gemspec

    gem 'nodevent'

nodevent expects a $redis global to exist and be a connect to your redis server.

4) Send some events

ActiveRecord Models:
```ruby
class SomeModel < ActiveRecord::Base
  include NoDevent
end

#Emit a model instance as a json object to that model
SomeModel.first.emit('the_event', SomeModel.first)

#Or just emit a message
NoDevent::Emitter.emit('the_room', 'the_event', 'the_message')

#You can also use an active record model as the room.
NoDevent::Emitter.emit(SomeModel.first, 'the_event', 'the_message')
```

3) Connect and listen for events in the browser
Load the socket.io layer:
```html
<%= javascript_include_nodevent %>
```

Connect to a room and listen for events
```javascript
  NoDevent.ready(
    {username : someuser}, function() {
      var theroom = NoDevent.join('someroom');
      theroom.on("the_event",function(data){
        /* Do stuff with data */
      });
    });

```

Thats it!

*Ok, so it's not that quick.

Use Cases
=======
- A 'realtime' chat server
- Showing online users
- Notify browsers when a resque job is done



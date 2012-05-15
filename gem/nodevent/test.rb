require './lib/nodevent.rb'
require 'redis'

$redis = Redis.new(:host => 'localhost', :port => '6379')

NoDevent::Emitter.emit("theroom", "theevent", "themessage")

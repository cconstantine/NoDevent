require 'digest/sha2'
require 'json'


module NoDevent

  def self.included(base)
    base.extend(NoDevent::Emitter)
  end

  def emit(name, messsage)
    Emitter.emit(self.room, name, message)
  end

  def room
    Emitter.room(self)
  end

  module Emitter
    @@secret = nil
    class << self
      def secret_token= val
          @@secret = val
      end
      def emit(room, name, message)
        $redis.publish("events", 
                       { :room => NoDevent::Emitter.room(room),
                         :event => name, 
                         :message => message}.to_json)
      end
      
      def room(obj)
        begin
          obj = "#{obj.class}_#{obj.id}"if (obj.is_a?(ActiveRecord::Base))
        rescue; end
        @@secret ? (Digest::SHA2.new << obj.to_s << @@secret).to_s : obj.to_s
      end
    end
  end
end

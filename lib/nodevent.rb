require 'digest/sha2'

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
        $redis.publish("events", {:room => NoDevent::Emitter.room(room), :event => name, :message => message}.to_json)
      end
      
      def room(obj)
        obj = "#{obj.class}_#{obj.id}"if (obj.is_a?(ActiveRecord::Base))
        (Digest::SHA2.new << obj.to_s << @@secret).to_s
      end
    end
  end
end

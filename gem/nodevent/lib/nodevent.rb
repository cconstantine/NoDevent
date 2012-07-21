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

  module Helper
    def javascript_include_nodevent
      host = URI.parse(NoDevent::Emitter.config[:host])
      namespace = URI.parse(NoDevent::Emitter.config[:namespace])

      params = [
                "host=#{host}",
                "namespace=#{namespace}"
               ].join("&")

      "<script src='#{Emitter.config[:host]}/api/#{namespace}' type='text/javascript'></script>".html_safe
    end    
  end
  ActionView::Base.send :include, Helper if defined?(ActionView::Base)

  module Emitter
    @@config = nil
    class << self
      def config= obj
        @@config = config.merge(obj)
      end

      def config
        @@config ||= Hash.new({
                                :host => "http://localhost:8080",
                                :namespace => "nodevent"
                              })
        @@config
      end

      def emit(room, name, message)
        $redis.publish("events", 
                       { :room => NoDevent::Emitter.room(room),
                         :event => name, 
                         :message => message}.to_json)
      end
      
      def room(obj)
        obj = "#{obj.class}_#{obj.to_param}" if (defined?(ActiveRecord::Base) && 
                                           obj.is_a?(ActiveRecord::Base))
        obj
      end

      def room_key(obj, expires)
        r = room(obj)
        ts = (expires.to_f*1000).to_i

        (Digest::SHA2.new << obj.to_s << ts.to_s<< @@config[:secret]).to_s
      end
    end
  end
end

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

      javascript_include_tag("<script src='#{Emitter.config[:host]}/api/#{namespace}' type='text/javascript'></script>").html_safe
    end    
  end
  ActionView::Base.send :include, Helper

  module Emitter
    @@config = nil
    class << self
      def config= obj
        @@config = config.merge(obj)
      end

      def config
        @@config = HashWithIndifferentAccess.new({
                                                   :host => "http://localhost:8080",
                                                   :namespace => ""
                                                 }) unless @@config
        @@config
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
        @@config[:secret] ? (Digest::SHA2.new << obj.to_s << @@config[:secret]).to_s : obj.to_s
      end
    end
  end
end

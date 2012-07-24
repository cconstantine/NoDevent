require 'spec_helper'

module ActiveRecord
  class Base;end
end

class ModelMock < ActiveRecord::Base
  include NoDevent::Base

  attr_accessor :to_param

  def initialize(param)
    @to_param = param
  end
  def to_json(options)
    '{"id":"#{to_param}"}'
  end
end

NoDevent::Emitter.config = {
  :host => "http://thehost",
  :namespace => "thenamespace", 
  :secret => "asdf"
}

describe NoDevent do
  describe "the class" do
    
    it { ModelMock.room.should == "ModelMock" }
    
    it "should emit to the right room" do
      $redis.should_receive(:publish).with("events", 
                                           {
                                             :room => "ModelMock", 
                                             :event => 'theevent', 
                                             :message => 'themessage'}.to_json)
      
      ModelMock.emit('theevent', 'themessage')
    end
    
    it "should create a key from the right room" do
      t = Time.now
      ts = (t.to_f*1000).to_i
      ModelMock.room_key(t).should == 
        (Digest::SHA2.new << "ModelMock" << ts.to_s << NoDevent::Emitter.config[:secret]).to_s
    end
    
    describe "with a custom room name" do
      before  do
        ModelMock.stub(:room => "otherRoom")
      end
      
      it { ModelMock.room.should == "otherRoom" }
      
      it "should emit to the right room" do
        $redis.should_receive(:publish).with("events", 
                                             {
                                               :room => "otherRoom", 
                                               :event => 'theevent', 
                                               :message => 'themessage'}.to_json)
        
        ModelMock.emit('theevent', 'themessage')
      end
      
      it "should create a key from the right room" do
        t = Time.now
        ts = (t.to_f*1000).to_i
        ModelMock.room_key(t).should == 
          (Digest::SHA2.new << ModelMock.room << ts.to_s << NoDevent::Emitter.config[:secret]).to_s
      end
    end  
  end
  
  describe "an instance of the class" do
    let(:instance) {ModelMock.new( 'theparam') }

    it { instance.room.should == "ModelMock_theparam" }
    it "should emit to the right room" do
      $redis.should_receive(:publish).with("events", 
                                           {
                                             :room => "ModelMock_theparam", 
                                             :event => 'theevent', 
                                             :message => 'themessage'}.to_json)
      
      instance.emit('theevent', 'themessage')
    end
    
    describe "#nodevent_create" do
      it "should emit to the right room" do
      $redis.should_receive(:publish).with("events", 
                                           {
                                             :room => "ModelMock", 
                                             :event => 'create', 
                                             :message => instance}.to_json)
        instance.nodevent_create
        
      end
    end
    describe "#nodevent_update" do
      it "should emit to the right room" do
      $redis.should_receive(:publish).with("events", 
                                           {
                                             :room => "ModelMock_theparam", 
                                             :event => 'update', 
                                             :message => instance}.to_json)
        instance.nodevent_update
        
      end
    end

    it "should create a key from the right room" do
      t = Time.now
      ts = (t.to_f*1000).to_i
      instance.room_key(t).should == 
        (Digest::SHA2.new << instance.room << ts.to_s << NoDevent::Emitter.config[:secret]).to_s
    end
    
    describe "with a custom room name" do
      before  do
        instance.stub(:room => "otherRoom")
      end
      
      it { instance.room.should == "otherRoom" }
      
      it "should emit to the right room" do
        $redis.should_receive(:publish).with("events", 
                                             {
                                               :room => "otherRoom", 
                                               :event => 'theevent', 
                                               :message => 'themessage'}.to_json)
        
        instance.emit('theevent', 'themessage')
      end
      
      it "should create a key from the right room" do
        t = Time.now
        ts = (t.to_f*1000).to_i
        instance.room_key(t).should == 
          (Digest::SHA2.new << "otherRoom" << ts.to_s << NoDevent::Emitter.config[:secret]).to_s
      end
      describe "#nodevent_create" do
        it "should emit to the right room" do
          $redis.should_receive(:publish).with("events", 
                                               {
                                                 :room => instance.class.room, 
                                                 :event => 'create', 
                                                 :message => instance}.to_json)
          instance.nodevent_create
          
        end
      end
      describe "#nodevent_update" do
        it "should emit to the right room" do
          $redis.should_receive(:publish).with("events", 
                                               {
                                                 :room => instance.room,
                                                 :event => 'update', 
                                                 :message => instance}.to_json)
          instance.nodevent_update
          
        end
      end  
    end
  end
 end

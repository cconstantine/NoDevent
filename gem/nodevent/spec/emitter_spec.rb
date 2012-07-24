require 'spec_helper'

module ActiveRecord
  class Base;end
end

describe NoDevent do
  
  describe "::Emitter" do

    describe "#config" do
      it "has a default config" do
        NoDevent::Emitter.config[:host].should be_present
        NoDevent::Emitter.config[:namespace].should be_present
      end

      it "lets you override the config" do
        NoDevent::Emitter.config = {:host => "foo", :namespace => "other"}
        
        NoDevent::Emitter.config[:host].should == "foo"
        NoDevent::Emitter.config[:namespace].should  == "other"
      end
    end
    describe "#room" do
      it "gives a room name" do
        NoDevent::Emitter.room('foo').should == 'foo'
      end
      it "converts an active record object into a string" do
        class SomeClass < ActiveRecord::Base
          def to_param
            "some_param"
          end
        end
        
        NoDevent::Emitter.room(SomeClass.new).should == "SomeClass_some_param"
      end
    end
  end
end
  

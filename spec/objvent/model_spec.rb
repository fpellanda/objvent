require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'eventmachine'
require "em-hiredis"
require 'fiber'
#class Foo; include Objvent::Model; end


require "redis/connection/synchrony"
require "redis"
require "redis/connection/ruby"

describe Objvent::Model do

  def pass
   # f = Fiber.current; EM.next_tick { f.resume }; Fiber.yield
  end

  around(:each) {|example|
    res = nil
    EM.synchrony do
      Redis::Objects.redis = Redis.new(REDIS_OPTIONS)
      res = example.run
    end
    res
  }
  before(:each) do Redis::Objects.redis.flushall end
  after(:each) do EM.stop end
  
  let!(:user_class) {
    # Define a model to test
    class User
      include Objvent::Model
    end
  }

  it "key should start with user" do
    user_class.redis_field_key(:state, "*").should == "user:*:state"
  end

  it "should throw exception if no uuid is given" do
    (-> { user_class.new }).should raise_error("No uuid given") 
  end

  context "empty user" do
    subject { user_class.new(uuid: "someid") }

    its("state.value") { should == "new" }

    it "should create a second new user" do
      # acces subject to create
      user_class.find_all.length.should == 0
      subject
      user_class.find_all.length.should == 1
      (-> {  user_class.new(uuid: "someid") }).should raise_error('User with uuid "someid" already exist')
      user_class.find_all.length.should == 1
    end
  end

  context "some user" do
    # Debugging: add debug printout into 
    #   lib/em-hiredis/connection.rb (receive_data/send_command)
    #   lib/redis/connection/synchrony.rb (write/read)
    #   EventMachine::Hiredis.logger.level = Logger::DEBUG
    subject { [user_class.new(uuid: "someid"),user_class.new(uuid: "otherid")] }
    
    it "Should delete user" do
      subject[0].attributes["d"] = "sdljk"
      user_class.find_all.count.should == 2
      user_class.delete_all
      user_class.find_all.count.should == 0
    end

    it "Should delete user" do
      subject[0].attributes["d"] = "sdljk"
      user_class.find_all.count.should == 2
      subject[1].delete
      user_class.find_all.count.should == 1
      subject[0].attributes["d"].should == "sdljk"
      subject[0].delete
      user_class.find_all.count.should == 0
      subject[0].attributes["d"].should == nil
    end
  end

  context "user message channel" do
    before(:each) { 
      user_class.instance_eval do
        attr_accessor :last_message
        on "message" do |msg|
          @last_message = msg
        end
      end
    }

    let(:user_instance) { user_class.new(uuid: "someuser") }
    it "should trigger a message" do
      user = user_instance
      pass
      user.trigger(:message, "the message")
      user.last_message.should == "the message"
    end
  end

  context "user message channel with options" do
    before(:each) { 
      user_class.instance_eval do
        attr_accessor :last_message, :last_options
        on "message" do |msg, options|
          @last_message = msg
          @last_options = options
        end
      end
    }

    let(:user_instance) { user_class.new(uuid: "someuser") }
    it "should trigger a message" do
      user = user_instance
      pass
      user.trigger(:message, "the message")
      pass
      user.last_message.should == "the message"
      user.last_options.should == {}
    end

    it "should trigger a message to another instance" do
      user = user_instance
      other_user_instance = user_class.find("someuser")

      user.trigger(:message, "the message")      

      user.last_message.should == "the message"
      user.last_options.should == {}
      other_user_instance.last_message.should == "the message"
      other_user_instance.last_options.should == {}
    end
  end

end

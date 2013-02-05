require 'redis/objects'
require 'active_support/concern'
require 'active_support/core_ext/hash'
#
# Ruby mixin for tracking object events from servers and clients
# connected by a redis server
#
# Example usage:
#
# class User
#   include Objvent::Model 
#
#   on :message do |msg|
#     puts "Message #{msg.inspect} from User #{self.id}"
#   end
#  
#   def write(message)
#     trigger message
#   end
#
# end
#
# With the above definition you can trigger events on instances of
# the User class.
#
#   user = User.find("anykey")
#   user.trigger("message", "Some message")
#
# Triggers a message on all connected hosts and browsers. This implies
# calling the "on :message do..." block above.
#
# The message on the console would be
#  'Message "Some message" from User anykey'


module Objvent::Model

  def self.redis
    # TODO: Just use one connection. Current implementation only supports
    #       one client per subscription
    #return @redis if @redis

    @redis = EM::Hiredis.connect("redis://127.0.0.1:9212")

    f = Fiber.current
    @redis.callback { f.resume }
    Fiber.yield
    return @redis
  end
  
  extend ActiveSupport::Concern

  included do
    include Redis::Objects
    value :state
    lock :state, expiration: 15
    hash_key :attributes
    attr_reader :uuid
  end

  module ClassMethods
    
    def attributes(*attrs)
      attrs.each {|attr|
        define_method attr do
          attributes[attr]
        end
      }
    end

    def find_all
      search = redis_field_key(:state, "*")
      regex = Regexp.new(("^" + Regexp.escape(search) + "$").sub("\\*","(.*)"))
      redis.keys(search).map do |key|
        raise "wrong key #{key.inspect}" unless key =~ regex
        self.find($1)
      end
    end

    def delete_all(id = "*")
      search = redis_field_key(:state, id).sub(":state",":*")
      keys = redis.keys(search)
      return if keys.length == 0
      redis.del keys
    end
    
    def find(uuid)
      self.new({uuid: uuid}, true)
    end
    
    def create!(attributes = {})
      attributes[:uuid] ||= UUID.new.generate
      self.new(attributes)
    end

    @@events ||= {}
    def events; @@events; end    
    def on(name, options = {}, &block)
      @@events[name.to_sym] = [options, block]
    end
    def trigger(instance, name, data, options)
      name = name.to_sym
      event = @@events[name]
      channel_name = instance.event_channel_name(name)
      redis.publish(channel_name, data)
      f = Fiber.current
      EM.next_tick {f.resume}
      Fiber.yield
    end
    def call_callback(instance, name, data, options = {})
      name = name.to_sym
      event = @@events[name]
      block = event[1]
      instance.instance_exec(data, options, &block)
    end
  end

  def initialize(attrs = {}, already_exist = false)
    attrs = attrs.symbolize_keys
    @uuid = attrs[:uuid]
    raise "No uuid given" unless @uuid
    state_lock.lock do
      if exist?
        raise "#{self.class.name} with uuid #{@uuid.inspect} already exist" unless already_exist
      else
        raise "#{self.class.name} with uuid #{@uuid.inspect} does not exist" if already_exist
      end
      state.value = "new"
      attributes.fill(attrs)      
    end    
    
    self.class.events.each {|name, eventdef|
      channel_name = event_channel_name(name)

      em_redis = Objvent::Model.redis    
      em_redis.subscribe(channel_name) 
      em_redis.on(:message) {|channel, message|
        self.class.call_callback(self, name, message)
      }
      f = Fiber.current
      EM.next_tick {f.resume}
      Fiber.yield
    }
  end
  
  def update_attributes(hash)
    attributes.update(hash)
  end
  
  def id
    @uuid
  end
  
  def delete
    self.class.delete_all(id)
  end
  
  def exist?
    !!state.value
  end
  
  def as_json(options = {})
    ret = attributes.all.dup
    ret[:id] = id
    ret
  end

  # EVENTS
  def event_channel_name(event_name)
    "#{self.class.redis_prefix(self.class)}:#{id}:event_#{event_name}"
  end
  def trigger(name, data, options = {})
    self.class.trigger(self, name, data, options)
  end

end

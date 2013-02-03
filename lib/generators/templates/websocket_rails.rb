WebsocketRails.setup do |config|

  # Change to :debug for debugging output
  config.log_level = :debug

  # Change to true to enable standalone server mode
  # Start the standalone server with rake websocket_rails:start_server
  # Requires Redis
  config.standalone = true

  # Change to true to enable channel synchronization between
  # multiple server instances. Requires Redis.
  config.synchronize = true

  # Uncomment and edit to point to a different redis instance.
  # Will not be used unless standalone or synchronization mode
  # is enabled.
  #config.redis_options = {:host => 'localhost', :port => '6379'}
end

class SpineController < WebsocketRails::BaseController

  def log(message)
    if WebsocketRails.log_level == :debug
      puts message
    end
  end

  def klass
    klass = message["class"].constantize
  end

  def attributes
    message["attributes"]
  end
  
  def create
    log "Spine event create #{message["class"].inspect} #{attributes.inspect}"
    klass.create!(attributes)
  end

  def update
    log "Spine event update #{message["class"].inspect} #{message["id"].inspect} #{attributes.inspect}"
    klass.find(message["id"]).update_attributes!(attributes)
  end

  def destroy
    log "Spine event destroy #{message["class"].inspect}"
    klass.destroy(message["id"])
  end
  
end

WebsocketRails::EventMap.describe do
  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:
  #   subscribe :client_connected, :to => Controller, :with_method => :method_name
  #
  # Here is an example of mapping namespaced events:
  #   namespace :product do
  #     subscribe :new, :to => ProductController, :with_method => :new_product
  #   end
  # The above will handle an event triggered on the client like `product.new`.
  
  namespace :spine do
    [:create, :update, :destroy].each {|type|
      subscribe type, to: SpineController, with_method: type
    }
  end

end


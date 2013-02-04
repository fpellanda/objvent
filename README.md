# Objvent

## Abstract

Keep your objectspace synchronized in ruby, rails and javascript with hightspeed. And the best, you can trigger events on objects and listen to them on server and client side!

## Rails 3.1 setup

Add this tou your Gemfile:

    gem "objevent"
    gem "spine-rails"
    gem "websocket_rails"

Then run

    bunle install
    # create spine application
    rails g spine:new
    rails g websocket_rails:install
    # initialize objvent (replace events.rb with new version)
    rails generate objvent:init

Add this toTo application.js (before require app)
    //= require objvent/main

## Usage

### Ruby

    class User
      include Objvent::Model 

      on :message do |msg|
        puts "Message #{msg.inspect} received on User #{self.id}"
      end
  
      def write(message)
        trigger message
      end
  
    end

### Javascript

    class App.User extends Spine.Model
      @configure 'User', 'email'
      @extend Spine.Model.Ajax.Methods
      @extend Objvent.Model
      
      objvents:
        "on message": "message"
  
      message: (msg) =>
        console.log("Message #{JSON.stringify(msg)} received on User #{@id}")
  
      writeMessage: (msg) ->
        @trigger("message", msg)

    end


  
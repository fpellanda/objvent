# Objvent

## Abstract

Keep your objectspace synchronized in ruby, rails and javascript with hightspeed. And the best, you can trigger events on objects and listen to them on server and client side!

## Rails 3.1 setup

Add this tou your Gemfile:

  gem "objevent"

Then run

  bunle install
  rails generate objvent:init

## Usage

### Ruby

  class User
    include Objvent::Model 

    on :message do |msg|
      puts "Message received: #{msg}"
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
      console.log("Message received: #{msg}"

    writeMessage: (msg) ->
      @trigger("message", msg)

  end


  
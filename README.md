# Objvent - DEPRECATED, NOT WORKING

## Abstract

Keep your objectspace synchronized in ruby, rails and javascript with hightspeed. And the best, you can trigger events on objects and listen to them on server and client side!

## Rails 3.1 setup

Add this tou your Gemfile:

````ruby
gem "objevent"
gem "spine-rails"
gem "websocket_rails"
````

Then run
````shell
bunle install
# create spine application
rails g spine:new
rails g websocket_rails:install
# initialize objvent (replace events.rb with new version)
rails generate objvent:init
````

Add this toTo application.js (before require app)
    //= require objvent/main

## Usage

### Ruby
````ruby
class User
  include Objvent::Model 

  on :message do |msg|
    puts "Message #{msg.inspect} from User #{self.id}"
  end
  
  def write(message)
    trigger message
  end

end
````

### Coffeescript
````coffeescript
class App.User extends Spine.Model
  @configure 'User', 'email'
  @extend Objvent.Model
      
  objvents:
    "on message": "message"
  
  message: (msg) =>
    console.log("Message #{JSON.stringify(msg)} from User #{@id}")
  
  writeMessage: (msg) ->
    @trigger("message", msg)
````

## Example
With the above Code examples it is possible to track events in ruby and javascript
code in realtime.
````
JS/Coffee in Browser                        | RUBY in Rails or Library

############### Load an existing user in ruby and JS ############################
> user = App.User.new("someuser")           | > user = User.find("someuser")
                                            |
############### Trigger a message in JS code         ############################
> user.trigger("message"; "Hello JS")       |
Browser console output:                     | Ruby console output:
 Mesage "Hello JS" from User someuser       |   Message "Hello JS" from User someuser
                                            |
############### Trigger a message in RUBY code       ############################
                                            | > user.trigger("message", "Hello RUBY")
Browser console output:                     | Ruby console output:
 Mesage "Hello RUBY" from User someuser     |   Message "Hello RUBY" from User someuser

````

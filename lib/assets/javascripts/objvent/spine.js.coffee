#
# Coffeescript mixin for tracking object events from servers and clients
# connected by a redis server. The mixin also extends the class with Spine.Model, so
# no explicit extend of Spine.Model needed.
#
# Example usage:
#   class App.User extends Spine.Model
#     @configure 'User', 'email'
#     @extend Objvent.Model
#       
#     objvents:
#       "on message": "message"
#   
#     message: (msg) =>
#       console.log("Message #{JSON.stringify(msg)} from User #{@id}")
#   
#     writeMessage: (msg) ->
#       @trigger("message", msg)
#
#
# With the above definition you can trigger events on instances of
# the User class.
#
#   user = App.User.find("anykey")
#   user.trigger("message", "Some message")
#
# Triggers a message on all connected hosts and browsers. This implies
# calling the "@message" function on the instance.
#
# The message on the browser console would be
#  'Message "Some message" from User anykey'

# class
Extend =
  spineClass: () ->
    @className

  create: (atts, options) ->
    dispatcher.trigger "spine.create", {class: @spineClass(), attributes: atts, options: options}  
# instance
Include =
  spineClass: () ->
    @constructor.spineClass()

  updateAttributes: (atts, options) ->
    dispatcher.trigger "spine.update", {id: @id, class: @spineClass(), attributes: atts, options: options}

  destroy: (options) ->
    dispatcher.trigger "spine.destroy", {id: @id, class: @spineClass(), options: options}

Spine =
  extended: ->
    @createOrig = @create
    @prototype.updateAttributesOrig = @prototype.updateAttributesOrig
    @prototype.destroyOrig = @prototype.destroy
    @extend Extend
    @include Include  

Spine.subscribe = =>
  spinechannel = dispatcher.subscribe("spine")

  spinechannel.bind 'create', (attrs) ->
    console.log("WS Spine create #{JSON.stringify(attrs)}")
    model = App[attrs.model]
    model.createOrig(attrs, ajax: false)

  spinechannel.bind 'update', (attrs) ->
    console.log("WS Spine update #{JSON.stringify(attrs)}")
    model = App[attrs.model]
    model.find(attrs.id).updateAttributesOrig(attrs, ajax: false)

  spinechannel.bind 'destroy', (attrs) ->
    console.log("WS Spine destroy #{JSON.stringify(attrs)}")
    model = App[attrs.model]
    model.find(attrs.id).destroyOrig(attrs.id, ajax: false)

window.Objvent.Spine = Spine
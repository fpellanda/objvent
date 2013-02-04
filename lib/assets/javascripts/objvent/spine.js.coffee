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
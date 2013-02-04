describe "Spine Module", ->

  beforeEach, ->
    App.User = class App.User extends Spine.Model
      @configure 'User', 'name'
      @extend Objvent.Model

      on:
        message: "message"

      message: (data) =>
        @last_message = data

    App.User.deleteAll()
    Objvent.dispatcher = {}
    Objvent.dispatcher.trigger = jasmine.createSpy()

  describe "create", ->
    App.User.create(id: 'someid')
    expect(Objvent.dispatcher.trigger).wasCalled().with("create", id: 'someid')

  context "existing user", ->

    beforeEach, ->
      @user = App.User.create(id, 'someid')

    it "should trigger destroy event", ->
      @user.destroy()
      expect(Objvent.dispatcher.trigger).wasCalled().with("destroy", id: 'someid')

    it "should trigger objvent event", ->
      @user.trigger("message", "abc")
      expect(Objvent.dispatcher.trigger).wasCalled().with("trigger", class: "User", id: "someid", data: "abc")

    it "should call bound method on event", ->
      Objvent.dispatcher.trigger("trigger", class: "User", id: "someid", event: "message", data: "abc")
      expect(@user.last_message).toBe("abc")

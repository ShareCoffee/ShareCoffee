chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.UI'

root = global ? window

describe 'ShareCoffee.UI', ->

  beforeEach () ->
    expected = webAbsoluteUrl : 'https://dotnetrocks.sharepoint.com'
    root._spPageContextInfo = expected
    root.document = { URL: 'http://dotnetrocks.sharepoint.com/Default.aspx?Foo=Bar', getElementById : ()-> } 
    root.FakeNavigation = 
      setVisible: ()-> 
    root.ShareCoffee.Core =
      checkConditions :()->
    root.SP = 
      UI : 
        Controls:
          Navigation: ()->
            FakeNavigation
        Notify:
          addNotification: ()->
            return 666
          removeNotification: ()->
        Status:
          addStatus: () -> 
            return 1
          setStatusPriColor:()->
          removeStatus:() ->
          removeAllStatus: ()->

  afterEach () ->
    delete root._spPageContextInfo 
    delete root.document
    delete root.SP

  describe 'showNotification', ->

    it 'should call addNotification on SP.UI.Notifiy with correpsonding parameters', ->
      message = 'foo'
      isSticky = true
      spy = sinon.spy SP.UI.Notify, "addNotification"
      ShareCoffee.UI.showNotification message, isSticky
      spy.calledWithExactly(message, isSticky).should.be.ok
      SP.UI.Notify.addNotification.restore()

    it 'should always return the notification id', ->
      message = 'foo'
      isSticky = true
      notificationId = ShareCoffee.UI.showNotification message, isSticky
      notificationId.should.equal 666

  describe 'removeNotification', ->

    it 'should call removeNotification with corresponding parameters', ->
      [message, isSticky] = ['foo', false]
      spy = sinon.spy SP.UI.Notify, 'removeNotification'
      ShareCoffee.UI.removeNotification 1
      spy.calledWithExactly(1).should.be.ok
      SP.UI.Notify.removeNotification.restore()

    it 'should not call removeNotification when notificationId is not present', ->
      [message, isSticky] = ['foo', false]
      spy = sinon.spy SP.UI.Notify, 'removeNotification'
      ShareCoffee.UI.removeNotification()
      spy.called.should.be.false
      SP.UI.Notify.removeNotification.restore()

  describe 'showStatus', ->

    it 'shoud call addStatus and setStatusPriColor with corresponding parameters', ->
      title = 'foo'
      contentAsHtml = '<b>bar</b>'
      showOnTop = false
      color = 'red'
      spy = sinon.spy SP.UI.Status, 'addStatus'
      setStatusPriColorSpy = sinon.spy SP.UI.Status, 'setStatusPriColor'

      ShareCoffee.UI.showStatus title, contentAsHtml, showOnTop, color
      
      spy.calledWithExactly(title, contentAsHtml, showOnTop).should.be.ok
      setStatusPriColorSpy.calledWithExactly(1,color).should.be.ok
      SP.UI.Status.addStatus.restore()
      SP.UI.Status.setStatusPriColor.restore()

    it 'should use blue color for status notifications if no color is present', ->
      title = 'foo'
      contentAsHtml = '<b>bar</b>'
      showOnTop = false
      spy = sinon.spy SP.UI.Status, 'addStatus'
      setStatusPriColorSpy = sinon.spy SP.UI.Status, 'setStatusPriColor'

      ShareCoffee.UI.showStatus title, contentAsHtml, showOnTop
      
      spy.calledWithExactly(title, contentAsHtml, showOnTop).should.be.ok
      setStatusPriColorSpy.calledWithExactly(1,'blue').should.be.ok
      SP.UI.Status.addStatus.restore()
      SP.UI.Status.setStatusPriColor.restore()

    it 'should return the id of the status', -> 
      title = 'foo'
      contentAsHtml = '<b>bar</b>'
      showOnTop = false

      statusId = ShareCoffee.UI.showStatus title, contentAsHtml, showOnTop
      statusId.should.equal 1

  describe 'removeStatus', ->
    
    it 'should call removeStatus with corresponding parameter', ->
      spy = sinon.spy SP.UI.Status, 'removeStatus'
      ShareCoffee.UI.removeStatus 1
      spy.calledWithExactly(1).should.be.ok
      SP.UI.Status.removeStatus.restore()

    it 'should not call removeStatus when no statusId has been passed', ->
      spy = sinon.spy SP.UI.Status, 'removeStatus'
      ShareCoffee.UI.removeStatus 
      spy.called.should.be.false
      SP.UI.Status.removeStatus.restore()

  describe 'removeAllStatus', ->

    it 'should call removeAllStatus on SP.UI.Status if present', ->
      spy = sinon.spy SP.UI.Status, 'removeAllStatus'
      ShareCoffee.UI.removeAllStatus()
      spy.called.should.be.true
      SP.UI.Status.removeAllStatus.restore()

  describe 'setStatusColor', ->

    it 'should call setStatusPriColor with corresponding parameters', ->
      statusId = 999
      color = 'yellow'
      spy = sinon.spy SP.UI.Status, 'setStatusPriColor'
      ShareCoffee.UI.setStatusColor statusId, color
      spy.calledWithExactly(statusId, color).should.be.ok
      SP.UI.Status.setStatusPriColor.restore()

    it 'should call setStatusPriColor with blue if no color is present', ->
      statusId = 999
      spy = sinon.spy SP.UI.Status, 'setStatusPriColor'
      ShareCoffee.UI.setStatusColor statusId
      spy.calledWithExactly(statusId, 'blue').should.be.ok
      SP.UI.Status.setStatusPriColor.restore()

    it 'should not call setStatusPriColor if statusId is not present', ->
      spy = sinon.spy SP.UI.Status, 'setStatusPriColor'
      ShareCoffee.UI.setStatusColor()
      spy.called.should.be.false

  describe 'loadAppChrome', ->
    beforeEach () ->
      ShareCoffee.Core = 
        loadScript: (url, onLoaded,onError) ->
          onLoaded() if onLoaded

    afterEach () ->
      delete ShareCoffee.Core

    it 'should store the callback within root callback store', ->
      callback = () ->
       1
      options = {}

      ShareCoffee.UI.loadAppChrome '', options, callback
      fakeResult = ShareCoffee.UI.onChromeLoadedCallback()
      fakeResult.should.equal 1
      
    it 'should store the root-callback within the options object', ->
      callback = () ->
        1
      options = {}
      ShareCoffee.UI.loadAppChrome '', options, callback
      options.onCssLoaded.should.equal 'ShareCoffee.UI.onChromeLoadedCallback()'

    it 'should not define a onCssLoaded property on the options object when no callback has been passed', ->
      options = {}
      ShareCoffee.UI.loadAppChrome '', options
      options.should.not.have.property 'onCssLoaded'

    it 'should call SP.UI.Controls.Navigation constructor with target id when script has been loaded sucessfully', ->
      placeHolderId = 'divChromeControlPlaceHolder'
      options = {}
      spy = sinon.spy SP.UI.Controls, 'Navigation'
      ShareCoffee.UI.loadAppChrome placeHolderId, options
      spy.calledWithExactly(placeHolderId, options).should.be.ok
      SP.UI.Controls.Navigation.restore()

    it 'should call setVisible on Controls.Navigation instance', ->
      placeHolderId = 'divChromControlPlaceHolder'
      options = {}
      spy = sinon.spy FakeNavigation, 'setVisible'
      ShareCoffee.UI.loadAppChrome placeHolderId, options
      spy.calledWithExactly(true).should.be.ok
      FakeNavigation.setVisible.restore()

    it 'should provide correct script url to loadScript method', ->
      stub = sinon.stub ShareCoffee.Commons, 'getHostWebUrl'
      stub.returns "https://foo.sharepoint.com/sites/dev"

      placeHolderId = 'divChromControlPlaceHolder'
      options = {}
      spy = sinon.spy ShareCoffee.Core, 'loadScript'
      ShareCoffee.UI.loadAppChrome placeHolderId, options
      spy.calledWith('https://foo.sharepoint.com/sites/dev/_layouts/15/SP.UI.Controls.js').should.be.ok
      ShareCoffee.Core.loadScript.restore()
      ShareCoffee.Commons.getHostWebUrl.restore()

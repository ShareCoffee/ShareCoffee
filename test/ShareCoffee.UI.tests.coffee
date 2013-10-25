chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.UI'
describe 'ShareCoffee.UI', ->

  beforeEach () ->
    expected = webAbsoluteUrl : 'https://dotnetrocks.sharepoint.com'
    global._spPageContextInfo = expected
    global.document = { URL: 'http://dotnetrocks.sharepoint.com/Default.aspx?Foo=Bar', getElementById : ()-> } 
    global.SP = 
      UI : 
        Notify:
          addNotification: ()->
        Status:
          addStatus: () -> 
            return 1
          setStatusPriColor:()->
          removeStatus:() ->
          removeAllStatus: ()->

  afterEach () ->
    delete global._spPageContextInfo 
    delete global.document
    delete global.SP
  describe 'showNotification', ->

    it 'should log an error if SP.UI or SP.UI.Notify is not defined', ->
      delete global.SP
      message = 'foo'
      isSticky = true
      spy = sinon.spy console, "error"
      ShareCoffee.UI.showNotification message, isSticky
      spy.calledWithExactly("SP, SP.UI or SP.UI.Notify is not defined (check if core.js is loaded)").should.be.ok
      console.error.restore()

    it 'should call addNotification on SP.UI.Notifiy with correpsonding parameters', ->
      message = 'foo'
      isSticky = true
      spy = sinon.spy SP.UI.Notify, "addNotification"
      ShareCoffee.UI.showNotification message, isSticky
      spy.calledWithExactly(message, isSticky).should.be.ok
      SP.UI.Notify.addNotification.restore()

  describe 'showStatus', ->

    it 'should log an error if SP SP.UI or SP.UI.Status is not defined', ->
      delete global.SP
      spy = sinon.spy console, 'error'
      ShareCoffee.UI.showStatus 'Foo','Bar', false
      spy.calledWithExactly("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)").should.be.ok
      console.error.restore()

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
    
    it 'should log an error if SP, SP.UI or SP.UI.Status are not present', ->
      delete global.SP
      spy = sinon.spy console, 'error'
      ShareCoffee.UI.removeStatus 1
      spy.calledWithExactly("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)").should.be.ok
      console.error.restore()

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

    it 'should log an error if SP, SP.UI or SP.UI.Status are not present', ->
      delete global.SP
      spy = sinon.spy console, 'error'
      ShareCoffee.UI.removeAllStatus()
      spy.calledWithExactly("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)").should.be.ok
      console.error.restore()

    it 'should call removeAllStatus on SP.UI.Status if present', ->
      spy = sinon.spy SP.UI.Status, 'removeAllStatus'
      ShareCoffee.UI.removeAllStatus()
      spy.called.should.be.true
      SP.UI.Status.removeAllStatus.restore()

  describe 'setStatusColor', ->

    it 'should log an error if SP, SP.UI or SP.UI.Status are not present', ->
      statusId = 2
      delete global.SP.UI.Status
      spy = sinon.spy console, 'error'
      ShareCoffee.UI.setColor statusId, 'red'
      spy.calledWithExactly("SP, SP.UI or SP.UI.Status is not defined! (check if core.js is loaded)").should.be.ok
      console.error.restore()

    it 'should call setStatusPriColor with corresponding parameters', ->
      statusId = 999
      color = 'yellow'
      spy = sinon.spy SP.UI.Status, 'setStatusPriColor'
      ShareCoffee.UI.setColor statusId, color
      spy.calledWithExactly(statusId, color).should.be.ok
      SP.UI.Status.setStatusPriColor.restore()

    it 'should call setStatusPriColor with blue if no color is present', ->
      statusId = 999
      spy = sinon.spy SP.UI.Status, 'setStatusPriColor'
      ShareCoffee.UI.setColor statusId
      spy.calledWithExactly(statusId, 'blue').should.be.ok
      SP.UI.Status.setStatusPriColor.restore()

    it 'should not call setStatusPriColor if statusId is not present', ->
      spy = sinon.spy SP.UI.Status, 'setStatusPriColor'
      ShareCoffee.UI.setColor()
      spy.called.should.be.false

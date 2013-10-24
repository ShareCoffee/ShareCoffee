chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.UI'
describe 'ShareCoffee.UI', ->

  beforeEach () ->
    expected = webAbsoluteUrl : 'https://dotnetrocks.sharepoint.com'
    global._spPageContextInfo = expected
    global.document = { URL: 'http://dotnetrocks.sharepoint.com/Default.aspx?Foo=Bar', getElementById : ()-> } 
    global.SP = { UI : { Notify:{ addNotification:()-> } } }

  afterEach () ->
    global._spPageContextInfo = undefined
    global.document = undefined

  describe 'displayNotification', ->

    it 'should log an error if SP.UI or SP.UI.Notify is not defined', ->
      delete global.SP
      message = 'foo'
      isSticky = true
      spy = sinon.spy console, "error"
      ShareCoffee.UI.showNotification message, isSticky
      spy.calledWithExactly("SP.UI or SP.UI.Notify is not loaded").should.be.ok
      console.error.restore()

    it 'should call addNotification on SP.UI.Notifiy with correpsonding parameters', ->
      message = 'foo'
      isSticky = true
      spy = sinon.spy SP.UI.Notify, "addNotification"
      ShareCoffee.UI.showNotification message, isSticky
      spy.calledWithExactly(message, isSticky).should.be.ok



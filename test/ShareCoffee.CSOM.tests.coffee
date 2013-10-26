chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.CSOM'

root = global ? window

describe 'ShareCoffee.CSOM', ->

  beforeEach () ->
    expected = webAbsoluteUrl : 'https://dotnetrocks.sharepoint.com'
    root._spPageContextInfo = expected
    root.document = { URL: 'http://dotnetrocks.sharepoint.com/Default.aspx?Foo=Bar', getElementById : ()-> } 
    root.SP = 
      Web: ()-> {}
      Context:
        get_web: ()-> 
          return new SP.Web()
      AppContextSite: ()->
        SP.Context

  afterEach () ->
    delete root._spPageContextInfo
    delete root.document

  describe 'getHostWeb', ->

    it 'should call AppContextSite constructor',->
      spy = sinon.spy SP, 'AppContextSite'
      fakeCtx = {}
      web = ShareCoffee.CSOM.getHostWeb fakeCtx, 'http://dotnetrocks.sharepoint.com/sites/hostweb'
      spy.calledWithExactly(fakeCtx, 'http://dotnetrocks.sharepoint.com/sites/hostweb').should.be.ok
      web.should.be.defined

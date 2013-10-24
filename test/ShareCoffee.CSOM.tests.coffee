chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.CSOM'
describe 'ShareCoffee.CSOM', ->

  beforeEach () ->
    expected = webAbsoluteUrl : 'https://dotnetrocks.sharepoint.com'
    global._spPageContextInfo = expected
    global.document = { URL: 'http://dotnetrocks.sharepoint.com/Default.aspx?Foo=Bar', getElementById : ()-> } 
    global.SP = 
      Web: ()-> {}
      Context:
        get_web: ()-> 
          return new SP.Web()
      AppContextSite: ()->
        SP.Context

  afterEach () ->
    delete global._spPageContextInfo
    delete global.document

  describe 'getHostWeb', ->

    it 'should call AppContextSite constructor',->
      spy = sinon.spy SP, 'AppContextSite'
      fakeCtx = {}
      web = ShareCoffee.CSOM.getHostWeb fakeCtx, 'http://dotnetrocks.sharepoint.com/sites/hostweb'
      spy.calledWithExactly(fakeCtx, 'http://dotnetrocks.sharepoint.com/sites/hostweb').should.be.ok
      web.should.be.defined

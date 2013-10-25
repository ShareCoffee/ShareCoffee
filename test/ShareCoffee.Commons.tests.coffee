chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.Commons'
describe 'ShareCoffee.Commons', ->

  beforeEach () ->
    expected = webAbsoluteUrl : 'https://dotnetrocks.sharepoint.com'
    global._spPageContextInfo = expected
    global.document = { URL: 'http://dotnetrocks.sharepoint.com/Default.aspx?Foo=Bar', getElementById : ()-> } 

  afterEach () ->
    delete global._spPageContextInfo
    delete global.document

  describe 'getQueryStringParameter', ->
    
    it 'should return query string parameter value if present', ->
      ShareCoffee.Commons.getQueryStringParameter('Foo').should.equal 'Bar'

    it 'should reutrn an empty string if parameter is not in query-string', ->
      ShareCoffee.Commons.getQueryStringParameter('bar').should.be.empty

  describe 'getAppWebUrl', ->
  
    it 'should return proper AppWebUrl', ->
      ShareCoffee.Commons.getAppWebUrl().should.equal 'https://dotnetrocks.sharepoint.com'
  
    it 'should return an empty string if Context or webAbsoluteUrl arent present', ->
      delete global._spPageContextInfo
      ShareCoffee.Commons.getAppWebUrl().should.be.empty
 
    it 'should call injected method if _spPageContextInfo is not present', ->
      delete global._spPageContextInfo
      ShareCoffee.Commons.loadAppWebUrlFrom = ()->
        "http://foo.sharepoint.com"
      actual = ShareCoffee.Commons.getAppWebUrl()
      actual.should.equal "http://foo.sharepoint.com"
      delete ShareCoffee.Commons.loadAppWebUrlFrom

    it 'should look for AppWebUrl also within the QueryString', ->
      delete global._spPageContextInfo
      global.document.URL = "#{global.document.URL}&SPAppWebUrl=https%3A%2F%2Ffoo.sharepoint.com"
      expected = "https://foo.sharepoint.com"
      actual = ShareCoffee.Commons.getAppWebUrl()
      actual.should.equal expected
    
    it 'should priorize custom load method if present', ->
      global.document.URL = "#{global.document.URL}&SPAppWebUrl=https%3A%2F%2Ffoo.sharepoint.com"
      ShareCoffee.Commons.loadAppWebUrlFrom = ()->
        "http://foo.sharepoint.com"
      actual = ShareCoffee.Commons.getAppWebUrl()
      actual.should.equal 'http://foo.sharepoint.com'
      delete ShareCoffee.Commons.loadAppWebUrlFrom

    it "should print the error to the console if _spPageContextInfo isn't present", ->
      delete global._spPageContextInfo
      spy = sinon.spy console, "error"   
      ShareCoffee.Commons.getAppWebUrl()
      spy.calledWithExactly("_spPageContextInfo is not defined").should.be.ok
      console.error.restore()
  
  describe 'GetApiRootUrl', ->
    
    it 'should return proper API root Url',->
      ShareCoffee.Commons.getApiRootUrl().should.equal "https://dotnetrocks.sharepoint.com/_api/"

  describe 'getFormDigest', ->

    it 'should return correct FormDigestValue', ->
      expectedRequestDigest = '123456567'
      stub = sinon.stub document, "getElementById"
      stub.returns {value : expectedRequestDigest}

      ShareCoffee.Commons.getFormDigest().should.equal expectedRequestDigest

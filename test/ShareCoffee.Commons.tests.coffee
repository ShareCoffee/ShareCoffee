chai = require 'chai'
sinon = require 'sinon'
should = chai.should()

require '../src/ShareCoffee.Commons'

root = global ? window
describe 'ShareCoffee.Commons', ->

  beforeEach () ->
    expected = webAbsoluteUrl : 'https://dotnetrocks.sharepoint.com'
    root._spPageContextInfo = expected
    root.document = { URL: 'http://dotnetrocks.sharepoint.com/Default.aspx?Foo=Bar', getElementById : ()-> } 

  afterEach () ->
    delete root._spPageContextInfo
    delete root.document

  describe 'getQueryString', ->
    
    it 'should return the entire querystring if present', ->
      ShareCoffee.Commons.getQueryString().should.equal 'Foo=Bar'

  describe 'getQueryStringParameter', ->
    
    it 'should return query string parameter value if present', ->
      ShareCoffee.Commons.getQueryStringParameter('Foo').should.equal 'Bar'

    it 'should reutrn an empty string if parameter is not in query-string', ->
      ShareCoffee.Commons.getQueryStringParameter('bar').should.be.empty

  describe 'getAppWebUrl', ->
  
    it 'should return proper AppWebUrl', ->
      ShareCoffee.Commons.getAppWebUrl().should.equal 'https://dotnetrocks.sharepoint.com'
  
    it 'should return an empty string if Context or webAbsoluteUrl arent present', ->
      delete root._spPageContextInfo
      ShareCoffee.Commons.getAppWebUrl().should.be.empty
 
    it 'should call injected load method present', ->
      delete root._spPageContextInfo
      ShareCoffee.Commons.loadAppWebUrlFrom = ()->
        "http://foo.sharepoint.com"
      actual = ShareCoffee.Commons.getAppWebUrl()
      actual.should.equal "http://foo.sharepoint.com"
      delete ShareCoffee.Commons.loadAppWebUrlFrom

    it 'should look for AppWebUrl also within the QueryString', ->
      delete root._spPageContextInfo
      root.document.URL = "#{root.document.URL}&SPAppWebUrl=https%3A%2F%2Ffoo.sharepoint.com"
      expected = "https://foo.sharepoint.com"
      actual = ShareCoffee.Commons.getAppWebUrl()
      actual.should.equal expected
    
    it 'should priorize custom load method if present', ->
      root.document.URL = "#{root.document.URL}&SPAppWebUrl=https%3A%2F%2Ffoo.sharepoint.com"
      ShareCoffee.Commons.loadAppWebUrlFrom = ()->
        "http://foo.sharepoint.com"
      actual = ShareCoffee.Commons.getAppWebUrl()
      actual.should.equal 'http://foo.sharepoint.com'
      delete ShareCoffee.Commons.loadAppWebUrlFrom

    it "should print the error to the console if _spPageContextInfo isn't present", ->
      delete root._spPageContextInfo
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

    it 'should return undefined when the request digest element cannot be found', ->
      stub = sinon.stub document, "getElementById"
      stub.returns undefined

      should.not.exist ShareCoffee.Commons.getFormDigest()

  describe 'getHostWebUrl', ->

    it 'should return given SPHostUrl from the QueryString', ->
      document.URL = "#{document.URL}&SPHostUrl=https%3A%2F%2Ffoo.sharepoint.com%2Fsites%2Fsample"
      expected = "https://foo.sharepoint.com/sites/sample"

      actual = ShareCoffee.Commons.getHostWebUrl()
      actual.should.equal expected
   
    it 'should inject custom load method if present', ->
      ShareCoffee.Commons.loadHostWebUrlFrom = () ->
        return "https://foo.sharepoint.com/sites/second-sample"
      actual = ShareCoffee.Commons.getHostWebUrl()
      actual.should.equal "https://foo.sharepoint.com/sites/second-sample"
      delete ShareCoffee.Commons.loadHostWebUrlFrom

    it "should print the error to the console if SPHostUrl isn't present", ->
      spy = sinon.spy console, "error"   
      ShareCoffee.Commons.getHostWebUrl()
      spy.calledWithExactly("SPHostUrl is not defined in the QueryString").should.be.ok
      console.error.restore()
    
    it 'should priorize custom load method if present', ->
      root.document.URL = "#{root.document.URL}&SPHostUrl=https%3A%2F%2Ffoo.sharepoint.com"
      ShareCoffee.Commons.loadHostWebUrlFrom = ()->
        "http://foo.sharepoint.com"
      actual = ShareCoffee.Commons.getHostWebUrl()
      actual.should.equal 'http://foo.sharepoint.com'
      delete ShareCoffee.Commons.loadHostWebUrlFrom


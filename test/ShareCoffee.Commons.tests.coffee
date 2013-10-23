chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.Commons'
describe 'ShareCoffee.Commons', ->

  beforeEach () ->
    expected = webAbsoluteUrl : 'https://dotnetrocks.sharepoint.com'
    global._spPageContextInfo = expected
    global.document = { getElementById : ()-> } 

  afterEach () ->
    global._spPageContextInfo = undefined
    global.document = undefined

  describe 'GetAppWebUrl', ->
  
    it 'should return proper AppWebUrl', ->
      ShareCoffee.Commons.getAppWebUrl().should.equal 'https://dotnetrocks.sharepoint.com'
  
    it 'should return an empty string if Context or webAbsoluteUrl arent present', ->
      global._spPageContextInfo = undefined
      ShareCoffee.Commons.getAppWebUrl().should.be.empty
  
    it "should print the error to the console if _spPageContextInfo isn't present", ->
      global._spPageContextInfo = undefined
      spy = sinon.spy console, "error"   
      ShareCoffee.Commons.getAppWebUrl()
      spy.calledWithExactly("_spPageContextInfo is not defined").should.be.ok
  
  describe 'GetApiRootUrl', ->
    
    it 'should return proper API root Url',->
      ShareCoffee.Commons.getApiRootUrl().should.equal "https://dotnetrocks.sharepoint.com/_api/"

  describe 'buildGetRequest', ->
    
    it 'should create a proper get request property object',->
      expected = 
        url : "https://dotnetrocks.sharepoint.com/_api/web/lists/?$Select=Title",
        type: "GET",
        headers: { 'Accepts' : 'application/json;odata=verbose'}
      ShareCoffee.Commons.buildGetRequest("web/lists/?$Select=Title").should.be.deep.equal expected

  describe 'getFormDigest', ->

    it 'should return correct FormDigestValue', ->
      expectedRequestDigest = '123456567'
      stub = sinon.stub document, "getElementById"
      stub.returns {value : expectedRequestDigest}

      ShareCoffee.Commons.getFormDigest().should.equal expectedRequestDigest

  describe 'buildDeleteRequest', ->

    it 'should create a proper delete reuqest property object', ->
      expectedRequestDigest = '123456567'
      stub = sinon.stub document, "getElementById"
      stub.returns {value : expectedRequestDigest}

      expected = 
        url : "https://dotnetrocks.sharepoint.com/_api/web/lists/GetByTitle('Documents')",
        type: 'DELETE',
        contentType: 'application/json;odata=verbose',
        headers: 
          'Accept' : 'application/json;odata=verbose',
          'If-Match': '*',
          'X-RequestDigest': expectedRequestDigest
      ShareCoffee.Commons.buildDeleteRequest("web/lists/GetByTitle('Documents')").should.be.deep.equal expected

  describe 'buildUpdateRequest', ->

    it 'should return a proper update request property object', ->
      expectedRequestDigest = '123456567'
      stub = sinon.stub document, "getElementById"
      stub.returns {value : expectedRequestDigest}
      etag = 'f88dd058fe004909615a64f01be66a7'
      requestPayload = "{'foo':'bar'}"
      expected = 
        url : "https://dotnetrocks.sharepoint.com/_api/web/lists/GetByTitle('Documents')",
        type: 'POST',
        contentType: 'application/json;odata=verbose',
        headers: 
          'Accept' : 'application/json;odata=verbose',
          'X-RequestDigest' : expectedRequestDigest,
          'X-HTTP-Method': 'MERGE',
          'If-Match' : etag
        data: requestPayload
      ShareCoffee.Commons.buildUpdateRequest("web/lists/GetByTitle('Documents')", etag, requestPayload).should.be.deep.equal expected

  describe 'buildCreateRequest', ->

    it 'should return a propert create request property object', ->
      expectedRequestDigest = '123456567'
      stub = sinon.stub document, "getElementById"
      stub.returns {value : expectedRequestDigest}
      requestPayload = "{'foo':'bar'}"
      expected = 
        url : "https://dotnetrocks.sharepoint.com/_api/web/lists/GetByTitle('Documents')",
        type: 'POST',
        contentType: 'application/json;odata=verbose',
        headers: 
          'Accept' : 'application/json;odata=verbose',
          'X-RequestDigest' : expectedRequestDigest
        data: requestPayload
      ShareCoffee.Commons.buildCreateRequest("web/lists/GetByTitle('Documents')", requestPayload).should.be.deep.equal expected

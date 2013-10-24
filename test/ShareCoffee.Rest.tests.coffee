chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.REST'
describe 'ShareCoffee.REST', ->

  beforeEach () ->
    expected = webAbsoluteUrl : 'https://dotnetrocks.sharepoint.com'
    global._spPageContextInfo = expected
    global.document = { URL: 'http://dotnetrocks.sharepoint.com/Default.aspx?Foo=Bar', getElementById : ()-> } 

  afterEach () ->
    delete global._spPageContextInfo 
    delete global.document 

  describe 'buildGetRequest', ->
    
    it 'should create a proper get request property object',->
      expected = 
        url : "https://dotnetrocks.sharepoint.com/_api/web/lists/?$Select=Title",
        type: "GET",
        headers: { 'Accepts' : 'application/json;odata=verbose'}
      ShareCoffee.REST.buildGetRequest("web/lists/?$Select=Title").should.be.deep.equal expected

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
      ShareCoffee.REST.buildDeleteRequest("web/lists/GetByTitle('Documents')").should.be.deep.equal expected

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
      ShareCoffee.REST.buildUpdateRequest("web/lists/GetByTitle('Documents')", etag, requestPayload).should.be.deep.equal expected

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
      ShareCoffee.REST.buildCreateRequest("web/lists/GetByTitle('Documents')", requestPayload).should.be.deep.equal expected

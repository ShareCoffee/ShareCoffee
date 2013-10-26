chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.REST'

root = global ? window

describe 'ShareCoffee.REST', ->  
  
  beforeEach () ->
    root.document = { URL: 'http://dotnetrocks.sharepoint.com/Default.aspx?Foo=Bar&?SPHostUrl=', getElementById : ()-> } 
    root.ShareCoffee.Commons = 
      getHostWebUrl: ()->
        "https://foo.sharepoint.com/sites/dev"
      getApiRootUrl: ()->
        "https://dotnetrocks.sharepoint.com/_api/"
      getFormDigest: ()->
        "1234567890"

  afterEach () ->
    delete root._spPageContextInfo 
    delete root.document 

  describe 'loadCrossDomainLibrary', ->

    beforeEach () ->
      root.ShareCoffee.Core = 
        loadScript: (url, onSuccess,onError) ->

    afterEach () ->
      delete root.ShareCoffee.Core

    it 'should call loadScript on ShareCoffee.Core with correct parameters', ->
      spy = sinon.spy ShareCoffee.Core, 'loadScript'
      ShareCoffee.REST.loadCrossDomainLibrary null, null
      spy.calledWithExactly('https://foo.sharepoint.com/sites/dev/_layouts/15/SP.RequestExecutor.js', null, null).should.be.ok
      spy.restore()

    it 'should fire onSuccess when loadScript succeeded', ->
      loadScriptStub = sinon.stub ShareCoffee.Core, 'loadScript', (url, s,e) ->
        s() if s
      onSuccess = sinon.spy()
      ShareCoffee.REST.loadCrossDomainLibrary onSuccess, null
      onSuccess.calledOnce.should.be.true
      loadScriptStub.restore()

    it 'should fire onError when loadScript failes', ->
      loadScriptStub = sinon.stub ShareCoffee.Core, 'loadScript', (url, s,e) ->
        e() if e
      onError = sinon.spy()
      ShareCoffee.REST.loadCrossDomainLibrary null, onError
      onError.calledOnce.should.be.true
      loadScriptStub.restore()

  describe 'buildGetRequest', ->
    
    it 'should create a proper get request property object',->
      expected = 
        url : "https://dotnetrocks.sharepoint.com/_api/web/lists/?$Select=Title",
        type: "GET",
        headers: { 'Accepts' : 'application/json;odata=verbose'}
      ShareCoffee.REST.buildGetRequest("web/lists/?$Select=Title").should.be.deep.equal expected

  describe 'buildDeleteRequest', ->

    it 'should create a proper delete reuqest property object', ->
      expected = 
        url : "https://dotnetrocks.sharepoint.com/_api/web/lists/GetByTitle('Documents')",
        type: 'DELETE',
        contentType: 'application/json;odata=verbose',
        headers: 
          'Accept' : 'application/json;odata=verbose',
          'If-Match': '*',
          'X-RequestDigest': '1234567890'
      ShareCoffee.REST.buildDeleteRequest("web/lists/GetByTitle('Documents')").should.be.deep.equal expected

  describe 'buildUpdateRequest', ->

    it 'should return a proper update request property object', ->
      etag = 'f88dd058fe004909615a64f01be66a7'
      requestPayload = "{'foo':'bar'}"
      expected = 
        url : "https://dotnetrocks.sharepoint.com/_api/web/lists/GetByTitle('Documents')",
        type: 'POST',
        contentType: 'application/json;odata=verbose',
        headers: 
          'Accept' : 'application/json;odata=verbose',
          'X-RequestDigest' : '1234567890',
          'X-HTTP-Method': 'MERGE',
          'If-Match' : etag
        data: requestPayload
      ShareCoffee.REST.buildUpdateRequest("web/lists/GetByTitle('Documents')", etag, requestPayload).should.be.deep.equal expected

  describe 'buildCreateRequest', ->

    it 'should return a propert create request property object', ->
      requestPayload = "{'foo':'bar'}"
      expected = 
        url : "https://dotnetrocks.sharepoint.com/_api/web/lists/GetByTitle('Documents')",
        type: 'POST',
        contentType: 'application/json;odata=verbose',
        headers: 
          'Accept' : 'application/json;odata=verbose',
          'X-RequestDigest' : '1234567890'
        data: requestPayload
      ShareCoffee.REST.buildCreateRequest("web/lists/GetByTitle('Documents')", requestPayload).should.be.deep.equal expected

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

  describe 'API', ->
    
    #ShareCoffee.REST.build.create.for.jQuery()
    
    it 'should provide build as an object',->
      ShareCoffee.REST.build.should.be.an 'object'

    it 'should provide build.read, build.update, build.delete, build.create as objects', ->
      ShareCoffee.REST.build.create.should.be.an 'object'
      ShareCoffee.REST.build.read.should.be.an 'object'
      ShareCoffee.REST.build.update.should.be.an 'object'
      ShareCoffee.REST.build.delete.should.be.an 'object'

    it 'should provide a for object all CRUD ops as object', ->
      forCreate = ShareCoffee.REST.build.create.for
      forRead = ShareCoffee.REST.build.read.for
      forUpdate = ShareCoffee.REST.build.update.for
      forDelete = ShareCoffee.REST.build.delete.for

      forCreate.should.be.an 'object'
      forRead.should.be.an 'object'
      forUpdate.should.be.an 'object'
      forDelete.should.be.an 'object'

      forCreate.should.have.property('method')
      forCreate.method.should.equal 'POST'
      forRead.should.have.property('method')
      forRead.method.should.equal 'GET'
      forUpdate.should.have.property('method')
      forUpdate.method.should.equal 'POST'
      forDelete.should.have.property('method')
      forDelete.method.should.equal 'DELETE'

    it 'should provide various options in order to create request property objects for different frameworks', ->
      ShareCoffee.REST.build.create.for.jQuery.should.be.an 'function'
      ShareCoffee.REST.build.create.for.angularJS.should.be.an 'function'
      ShareCoffee.REST.build.create.for.reqwest.should.be.an 'function'

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

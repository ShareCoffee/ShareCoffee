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
      ShareCoffee.REST.build.create.for.SPCrossDomainLib.should.be.an 'function'

  describe 'SharePoint CrossDomain Library REST request object creator', ->
    
    it 'should return an object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      sut.SPCrossDomainLib().should.be.an 'object'
    
    it 'should contain the required URL in RequestExecutors format as url property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.SPCrossDomainLib 'web/title',null,null, ShareCoffee.Commons.getHostWebUrl()
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppContextSite(@target)/web/title?@target='https://foo.sharepoint.com/sites/dev'"

    it 'should use SPHostUrl if hostWebUrl is not passed for building the URL', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.SPCrossDomainLib 'web/title'
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppContextSite(@target)/web/title?@target='https://foo.sharepoint.com/sites/dev'"

    it 'should provide HttpMethod as method property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.SPCrossDomainLib 'foo'
      actual.should.have.property 'method'
      actual.method.should.be.an 'string'
      actual.method.should.equal 'GET'

    it 'should set success handler if present', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      onSuccess = ()->
      actual = sut.SPCrossDomainLib 'web/title', onSuccess
      actual.should.have.property 'success'
      actual.success.should.be.an 'function'
      actual.success.should.equal onSuccess

    it 'should not set success handler if present', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.SPCrossDomainLib 'web/title'
      actual.should.not.have.property 'success'

    it 'should set error handler if present', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      onError = ()->
      actual = sut.SPCrossDomainLib 'web/title', null, onError
      actual.should.have.property 'error'
      actual.error.should.be.an 'function'
      actual.error.should.equal onError

    it 'should not set error handler if present', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.SPCrossDomainLib 'web/title'
      actual.should.not.have.property 'error'
    
    it 'should provide a headers object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.SPCrossDomainLib 'foo'
      actual.should.have.property 'headers'
      actual.headers.should.be.an 'object'
    
    it 'should provide a Accept property within headers object containing current applicationType as string value', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.SPCrossDomainLib 'foo'
      actual.headers.should.have.property 'Accept'
      actual.headers.Accept.should.be.an 'string'
      actual.headers.Accept.should.equal ShareCoffee.REST.applicationType

    it 'should provide the X-RequestDigest property on headers if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.SPCrossDomainLib 'foo'
      actual.headers.should.have.property 'X-RequestDigest'
      actual.headers['X-RequestDigest'].should.be.an 'string'
      actual.headers['X-RequestDigest'].should.equal '1234567890'

    it 'should not provide a headers.X-RequestDigest proeprty if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.SPCrossDomainLib 'foo'
      actual.headers.should.not.have.property 'X-RequestDigest'

    it 'should provide a Content-Type property within headers object containing current applicationType if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.SPCrossDomainLib 'foo'
      actual.headers.should.have.property 'Content-Type'
      actual.headers['Content-Type'].should.be.an 'string'
      actual.headers['Content-Type'].should.equal ShareCoffee.REST.applicationType

    it 'should not provide a Content-Type property within headers if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.SPCrossDomainLib 'foo'
      actual.headers.should.not.have.property 'Content-Type'

    it 'should provide a If-Match property with value * if mathod is DELETE', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.SPCrossDomainLib 'foo'
      actual.headers.should.have.property 'If-Match'
      actual.headers['If-Match'].should.be.an 'string'
      actual.headers['If-Match'].should.equal '*'

    it 'should not provide an If-Match property if method is not DELETE expecting etag is passed and method is POST', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.SPCrossDomainLib 'foo'
      actual.headers.should.not.have.property 'If-Match'

      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.SPCrossDomainLib 'foo', null,null,null, '{"data":"foo"}','etag'
      actual2.headers.should.have.property 'If-Match'
      actual2.headers['If-Match'].should.equal 'etag'

      sut3 = new ShareCoffee.RESTFactory 'POST'
      actual3 = sut3.SPCrossDomainLib 'foo','{"d":"data"}'
      actual3.headers.should.not.have.property 'If-Match'

    it 'should provide a X-HTTP-Method header property with value MERGE only if method is POST and etag is given', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.SPCrossDomainLib 'foo', null,null,null,'{"d":"data"}','etag'
      actual.headers.should.have.property 'X-HTTP-Method'
      actual.headers['X-HTTP-Method'].should.be.an 'string'
      actual.headers['X-HTTP-Method'].should.equal 'MERGE'

    it 'should not have an X-HTTP-Method header property if method is not POST and etag is not given', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.SPCrossDomainLib 'foo'
      actual.headers.should.not.have.property 'X-HTTP-Method'
      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.SPCrossDomainLib 'foo'
      actual2.headers.should.not.have.property 'X-HTTP-Method'
      sut3 = new ShareCoffee.RESTFactory 'GET'
      actual3 = sut3.SPCrossDomainLib 'foo'
      actual3.headers.should.not.have.property 'X-HTTP-Method'

    it 'should provide payload as body property if method is POST', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = "{'a': 'b'}"
      actual = sut.SPCrossDomainLib 'foo', null,null,null,payload
      actual.should.have.property 'body'
      actual.body.should.equal payload

    it 'should not provide a body property if method is not POST', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      payload = "{'a': 'b'}"
      actual = sut.SPCrossDomainLib 'foo',null,null,null, payload
      actual.should.not.have.property 'body'

    it 'should stringify the payload if it is not given as string', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = 
        name: 'foo'
      expected = JSON.stringify payload
      actual = sut.SPCrossDomainLib 'foo', null,null,null, payload
      actual.body.should.equal expected


  describe 'reqwest REST request object creator', ->
    
    it 'should return an object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      sut.reqwest().should.be.an 'object'

    it 'should contain passed url combined with AppWeb API endpoint as url property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest 'web/title'
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal 'https://dotnetrocks.sharepoint.com/_api/web/title'

    it 'should contain correct url for HostWeb access if hostWebUrl is given', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest 'web/title', ShareCoffee.Commons.getHostWebUrl()
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppSiteContext(@target)/web/title?@target='https://foo.sharepoint.com/sites/dev'"

    it 'should provide HttpMethod as method property of type string containing the method in lowered case', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest 'foo'
      actual.should.have.property 'method'
      actual.method.should.be.an 'string'
      actual.method.should.equal 'get'

    it 'should provide a headers object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest 'foo'
      actual.should.have.property 'headers'
      actual.headers.should.be.an 'object'
    
    it 'should provide a Accept property within headers object containing current applicationType as string value', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest 'foo'
      actual.headers.should.have.property 'Accept'
      actual.headers.Accept.should.be.an 'string'
      actual.headers.Accept.should.equal ShareCoffee.REST.applicationType

    it 'should provide a contentType property if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.reqwest 'foo'
      actual.should.have.property 'contentType'
      actual.contentType.should.be.an 'string'
      actual.contentType.should.equal ShareCoffee.REST.applicationType

    it 'should not provide a contentType property if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest 'foo'
      actual.should.not.have.property 'contentType'

    it 'should provide the X-RequestDigest property on headers if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.reqwest 'foo'
      actual.headers.should.have.property 'X-RequestDigest'
      actual.headers['X-RequestDigest'].should.be.an 'string'
      actual.headers['X-RequestDigest'].should.equal '1234567890'

    it 'should not provide a headers.X-RequestDigest proeprty if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest 'foo'
      actual.headers.should.not.have.property 'X-RequestDigest'

    it 'should provide payload as data property if method is POST', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = 
        a:'b'
      actual = sut.reqwest 'foo',null, payload
      actual.should.have.property 'data'
      actual.data.should.be.an 'object'
      actual.data.should.equal payload

    it 'should not provide a data property if method is not POST', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      payload = 
        a: 'b'
      actual = sut.reqwest 'foo', null, payload
      actual.should.not.have.property 'data'

    it 'should parse the payload to an object if it is a string', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = '{"name":"foo"}'
      actual = sut.reqwest 'foo', null, payload
      JSON.stringify(actual.data).should.equal payload

    it 'should throw an error when neither an object nor an valid json string is passed as payload', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = 'Hello SharePoint'
      (-> sut.reqwest('foo', null, payload)).should.throw 'please provide either a json string or an object as payload'

    it 'should provide a If-Match property with value * if mathod is DELETE', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.reqwest 'foo'
      actual.headers.should.have.property 'If-Match'
      actual.headers['If-Match'].should.be.an 'string'
      actual.headers['If-Match'].should.equal '*'

    it 'should not provide an If-Match property if method is not DELETE expecting etag is passed and method is POST', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest 'foo'
      actual.headers.should.not.have.property 'If-Match'

      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.reqwest 'foo', null, '{"data":"foo"}','etag'
      actual2.headers.should.have.property 'If-Match'
      actual2.headers['If-Match'].should.equal 'etag'

      sut3 = new ShareCoffee.RESTFactory 'POST'
      actual3 = sut3.reqwest 'foo', null, '{"d":"data"}'
      actual3.headers.should.not.have.property 'If-Match'

    it 'should provide a X-HTTP-Method header property with value MERGE only if method is POST and etag is given', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.reqwest 'foo', null, '{"d":"data"}','etag'
      actual.headers.should.have.property 'X-HTTP-Method'
      actual.headers['X-HTTP-Method'].should.be.an 'string'
      actual.headers['X-HTTP-Method'].should.equal 'MERGE'

    it 'should not have an X-HTTP-Method header property if method is not POST and etag is not given', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.reqwest 'foo'
      actual.headers.should.not.have.property 'X-HTTP-Method'
      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.reqwest 'foo'
      actual2.headers.should.not.have.property 'X-HTTP-Method'
      sut3 = new ShareCoffee.RESTFactory 'GET'
      actual3 = sut3.reqwest 'foo'
      actual3.headers.should.not.have.property 'X-HTTP-Method'

  describe 'angularJS REST request object creator', ->

    it 'should return an object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      sut.angularJS().should.be.an 'object'

    it 'should contain passed url combined with AppWeb API endpoint as url property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS 'web/title'
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal 'https://dotnetrocks.sharepoint.com/_api/web/title'

    it 'should contain correct url for HostWeb access if hostWebUrl is given', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS 'web/title', ShareCoffee.Commons.getHostWebUrl()
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppSiteContext(@target)/web/title?@target='https://foo.sharepoint.com/sites/dev'"

    it 'should provide HttpMethod as method property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS 'foo'
      actual.should.have.property 'method'
      actual.method.should.be.an 'string'
      actual.method.should.equal 'GET'

    it 'should provide a headers object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS 'foo'
      actual.should.have.property 'headers'
      actual.headers.should.be.an 'object'
    
    it 'should provide a Accept property within headers object containing current applicationType as string value', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS 'foo'
      actual.headers.should.have.property 'Accept'
      actual.headers.Accept.should.be.an 'string'
      actual.headers.Accept.should.equal ShareCoffee.REST.applicationType

    it 'should provide a Content-Type property within headers object containing current applicationType if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.angularJS 'foo'
      actual.headers.should.have.property 'Content-Type'
      actual.headers['Content-Type'].should.be.an 'string'
      actual.headers['Content-Type'].should.equal ShareCoffee.REST.applicationType

    it 'should not provide a Content-Type property within headers if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS 'foo'
      actual.headers.should.not.have.property 'Content-Type'

    it 'should provide the X-RequestDigest property on headers if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.angularJS 'foo'
      actual.headers.should.have.property 'X-RequestDigest'
      actual.headers['X-RequestDigest'].should.be.an 'string'
      actual.headers['X-RequestDigest'].should.equal '1234567890'

    it 'should not provide a headers.X-RequestDigest proeprty if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS 'foo'
      actual.headers.should.not.have.property 'X-RequestDigest'

    it 'should provide payload as data property if method is POST', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = "{'a': 'b'}"
      actual = sut.angularJS 'foo', null, payload
      actual.should.have.property 'data'
      actual.data.should.equal payload

    it 'should not provide a data property if method is not POST', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      payload = "{'a': 'b'}"
      actual = sut.angularJS 'foo', null, payload
      actual.should.not.have.property 'data'

    it 'should stringify the payload if it is not given as string', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = 
        name: 'foo'
      expected = JSON.stringify payload
      actual = sut.angularJS 'foo', null, payload
      actual.data.should.equal expected

    it 'should provide a If-Match property with value * if mathod is DELETE', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.angularJS 'foo'
      actual.headers.should.have.property 'If-Match'
      actual.headers['If-Match'].should.be.an 'string'
      actual.headers['If-Match'].should.equal '*'

    it 'should not provide an If-Match property if method is not DELETE expecting etag is passed and method is POST', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS 'foo'
      actual.headers.should.not.have.property 'If-Match'

      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.angularJS 'foo', null, 'data','etag'
      actual2.headers.should.have.property 'If-Match'
      actual2.headers['If-Match'].should.equal 'etag'

      sut3 = new ShareCoffee.RESTFactory 'POST'
      actual3 = sut3.angularJS 'foo',null, 'data'
      actual3.headers.should.not.have.property 'If-Match'

    it 'should provide a X-HTTP-Method header property with value MERGE only if method is POST and etag is given', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.angularJS 'foo', null, 'data', 'etag'
      actual.headers.should.have.property 'X-HTTP-Method'
      actual.headers['X-HTTP-Method'].should.be.an 'string'
      actual.headers['X-HTTP-Method'].should.equal 'MERGE'

    it 'should not have an X-HTTP-Method header property if method is not POST and etag is not given', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.angularJS 'foo'
      actual.headers.should.not.have.property 'X-HTTP-Method'
      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.angularJS 'foo'
      actual2.headers.should.not.have.property 'X-HTTP-Method'
      sut3 = new ShareCoffee.RESTFactory 'GET'
      actual3 = sut3.angularJS 'foo'
      actual3.headers.should.not.have.property 'X-HTTP-Method'

  describe 'jQuery REST request object creator', ->
    
    it 'should return an object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      sut.jQuery().should.be.an 'object'
  
    it 'should contain passed url combined with AppWeb API endpoint as url property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery 'web/title'
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal 'https://dotnetrocks.sharepoint.com/_api/web/title'

    it 'should contain correct url for HostWeb access if hostWebUrl is given', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery 'web/title', ShareCoffee.Commons.getHostWebUrl()
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppSiteContext(@target)/web/title?@target='https://foo.sharepoint.com/sites/dev'"

    it 'should provide HttpMethod as type property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery 'foo'
      actual.should.have.property 'type'
      actual.type.should.be.an 'string'
      actual.type.should.equal 'GET'

    it 'should provide a headers object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery 'foo'
      actual.should.have.property 'headers'
      actual.headers.should.be.an 'object'

    it 'should provide a Accept property within headers object containing current applicationType as string value', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery 'foo'
      actual.headers.should.have.property 'Accept'
      actual.headers.Accept.should.be.an 'string'
      actual.headers.Accept.should.equal ShareCoffee.REST.applicationType

    it 'should provide a contentType property if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.jQuery 'foo'
      actual.should.have.property 'contentType'
      actual.contentType.should.be.an 'string'
      actual.contentType.should.equal ShareCoffee.REST.applicationType

    it 'should not provide a contentType property if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery 'foo'
      actual.should.not.have.property 'contentType'

    it 'should provide the X-RequestDigest property on headers if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.jQuery 'foo'
      actual.headers.should.have.property 'X-RequestDigest'
      actual.headers['X-RequestDigest'].should.be.an 'string'
      actual.headers['X-RequestDigest'].should.equal '1234567890'

    it 'should not provide a headers.X-RequestDigest proeprty if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery 'foo'
      actual.headers.should.not.have.property 'X-RequestDigest'

    it 'should provide payload as data property if method is POST', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = "{'a': 'b'}"
      actual = sut.jQuery 'foo', null, payload
      actual.should.have.property 'data'
      actual.data.should.equal payload

    it 'should not provide a data property if method is not POST', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      payload = "{'a': 'b'}"
      actual = sut.jQuery 'foo', null, payload
      actual.should.not.have.property 'data'

    it 'should stringify the payload if it is not given as string', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = 
        name: 'foo'
      expected = JSON.stringify payload
      actual = sut.jQuery 'foo', null, payload
      actual.data.should.equal expected
    
    it 'should provide a If-Match property with value * if mathod is DELETE', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.jQuery 'foo'
      actual.headers.should.have.property 'If-Match'
      actual.headers['If-Match'].should.be.an 'string'
      actual.headers['If-Match'].should.equal '*'

    it 'should not provide an If-Match property if method is not DELETE expecting etag is passed and method is POST', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery 'foo'
      actual.headers.should.not.have.property 'If-Match'

      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.jQuery 'foo', null, 'data', 'etag'
      actual2.headers.should.have.property 'If-Match'
      actual2.headers['If-Match'].should.equal 'etag'

      sut3 = new ShareCoffee.RESTFactory 'POST'
      actual3 = sut3.jQuery 'foo', null, 'data'
      actual3.headers.should.not.have.property 'If-Match'

    it 'should provide a X-HTTP-Method header property with value MERGE only if method is POST and etag is given', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.jQuery 'foo', null, 'data', 'etag'
      actual.headers.should.have.property 'X-HTTP-Method'
      actual.headers['X-HTTP-Method'].should.be.an 'string'
      actual.headers['X-HTTP-Method'].should.equal 'MERGE'

    it 'should not have an X-HTTP-Method header property if method is not POST and etag is not given', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.jQuery 'foo'
      actual.headers.should.not.have.property 'X-HTTP-Method'
      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.jQuery 'foo'
      actual2.headers.should.not.have.property 'X-HTTP-Method'
      sut3 = new ShareCoffee.RESTFactory 'GET'
      actual3 = sut3.jQuery 'foo'
      actual3.headers.should.not.have.property 'X-HTTP-Method'

  describe 'buildGetRequest', ->
    
    it 'should create a proper get request property object',->
      expected = 
        url : "https://dotnetrocks.sharepoint.com/_api/web/lists/?$Select=Title",
        type: "GET",
        headers: { 'Accept' : 'application/json;odata=verbose'}
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

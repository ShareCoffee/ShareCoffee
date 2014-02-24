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

    it 'should provide a "for" object for all CRUD ops as object', ->
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
      forUpdate.updateQuery.should.be.true
      forDelete.should.have.property('method')
      forDelete.method.should.equal 'DELETE'

    it 'should provide various options in order to create request property objects for different frameworks', ->
      ShareCoffee.REST.build.create.for.jQuery.should.be.an 'function'
      ShareCoffee.REST.build.create.for.angularJS.should.be.an 'function'
      ShareCoffee.REST.build.create.for.reqwest.should.be.an 'function'

  describe 'reqwest REST request object creator', ->

    it 'should return an object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      sut.reqwest().should.be.an 'object'

     it 'should call getRequestProperties on properties object if method is present (AddOnIntegration)', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      fakeRequestProperties =
        url : 'search/suggest'
        getRequestProperties: () =>

      spy = sinon.spy fakeRequestProperties, 'getRequestProperties'
      actual = sut.reqwest fakeRequestProperties
      spy.calledOnce.should.be.true
      fakeRequestProperties.getRequestProperties.restore()

    it 'should explicitly set reqwest type to json', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest { url: 'foo'}
      actual.should.have.property 'type'
      actual.type.should.equal 'json'

    it 'should contain passed url combined with AppWeb API endpoint as url property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest {url: 'web/title'}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal 'https://dotnetrocks.sharepoint.com/_api/web/title'

    it 'should contain correct url for HostWeb access if hostWebUrl is given', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest { url: 'web/title', hostWebUrl: ShareCoffee.Commons.getHostWebUrl()}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppContextSite(@target)/web/title?@target='https://foo.sharepoint.com/sites/dev'"

    it 'should contain correct url for HostWeb access if hostWebUrl is given and already a parameter in url exists', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest {url: 'web/?$Select=Title', hostWebUrl: ShareCoffee.Commons.getHostWebUrl()}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppContextSite(@target)/web/?$Select=Title&@target='https://foo.sharepoint.com/sites/dev'"

    it 'should provide HttpMethod as method property of type string containing the method in lowered case', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest {url: 'foo'}
      actual.should.have.property 'method'
      actual.method.should.be.an 'string'
      actual.method.should.equal 'get'

    it 'should provide a headers object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest {url: 'foo'}
      actual.should.have.property 'headers'
      actual.headers.should.be.an 'object'

    it 'should provide a Accept property within headers object containing current applicationType as string value', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest {url: 'foo'}
      actual.headers.should.have.property 'Accept'
      actual.headers.Accept.should.be.an 'string'
      actual.headers.Accept.should.equal ShareCoffee.REST.applicationType

    it 'should store onSuccess handler in success property if given',->
      sut = new ShareCoffee.RESTFactory 'GET'
      onSuccess = ()->
      actual = sut.reqwest {url: 'foo', onSuccess: onSuccess}
      actual.should.have.property 'success'
      actual.success.should.be.an 'function'

    it 'should not provide an success property if no handler present', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest {url: 'foo'}
      actual.should.not.have.property 'success'

    it 'should store onError handler in error property if given',->
      sut = new ShareCoffee.RESTFactory 'GET'
      onError = ()->
      actual = sut.reqwest {url: 'foo', onError: onError}
      actual.should.have.property 'error'
      actual.error.should.be.an 'function'

    it 'should not provide an error property if no handler present', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest {url: 'foo'}
      actual.should.not.have.property 'error'


    it 'should provide a contentType property if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.reqwest {url: 'foo'}
      actual.should.have.property 'contentType'
      actual.contentType.should.be.an 'string'
      actual.contentType.should.equal ShareCoffee.REST.applicationType

    it 'should not provide a contentType property if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest {url: 'foo'}
      actual.should.not.have.property 'contentType'

    it 'should provide the X-RequestDigest property on headers if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.reqwest {url: 'foo'}
      actual.headers.should.have.property 'X-RequestDigest'
      actual.headers['X-RequestDigest'].should.be.an 'string'
      actual.headers['X-RequestDigest'].should.equal '1234567890'

    it 'should not provide a headers.X-RequestDigest proeprty if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest {url: 'foo'}
      actual.headers.should.not.have.property 'X-RequestDigest'

    it 'should provide payload as data property if method is POST', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload =
        a:'b'
      actual = sut.reqwest {url: 'foo', payload: payload}
      actual.should.have.property 'data'
      actual.data.should.be.an 'string'
      actual.data.should.equal JSON.stringify(payload)

    it 'should not provide a data property if method is not POST', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      payload =
        a: 'b'
      actual = sut.reqwest {url: 'foo', payload: payload}
      actual.should.not.have.property 'data'

    it 'should parse the payload to an string if it is a object', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = name:"foo"
      actual = sut.reqwest {url: 'foo', payload: payload}
      actual.data.should.equal JSON.stringify(payload)

    it 'should provide a If-Match property with value * if mathod is DELETE', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.reqwest {url: 'foo'}
      actual.headers.should.have.property 'If-Match'
      actual.headers['If-Match'].should.be.an 'string'
      actual.headers['If-Match'].should.equal '*'

    it 'should not provide an If-Match property if method is not DELETE expecting etag is passed and method is POST', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.reqwest {url: 'foo'}
      actual.headers.should.not.have.property 'If-Match'

      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.reqwest {url:'foo', payload: '{"data":"foo"}', eTag: 'etag'}
      actual2.headers.should.have.property 'If-Match'
      actual2.headers['If-Match'].should.equal 'etag'

      sut3 = new ShareCoffee.RESTFactory 'POST'
      actual3 = sut3.reqwest {url: 'foo', payload: '{"d":"data"}'}
      actual3.headers.should.not.have.property 'If-Match'

    it 'should set eTag to * if update query is created and no eTag passed', ->
      sut = new ShareCoffee.RESTFactory 'POST',true
      actual = sut.reqwest {url: 'foo'}
      actual.headers['If-Match'].should.equal '*'

    it 'should provide a X-HTTP-Method header property with value MERGE only if method is POST and etag is given', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.reqwest {url: 'foo', payload: '{"d":"data"}', eTag: 'etag'}
      actual.headers.should.have.property 'X-HTTP-Method'
      actual.headers['X-HTTP-Method'].should.be.an 'string'
      actual.headers['X-HTTP-Method'].should.equal 'MERGE'

    it 'should not have an X-HTTP-Method header property if method is not POST and etag is not given', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.reqwest {url: 'foo'}
      actual.headers.should.not.have.property 'X-HTTP-Method'
      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.reqwest {url: 'foo'}
      actual2.headers.should.not.have.property 'X-HTTP-Method'
      sut3 = new ShareCoffee.RESTFactory 'GET'
      actual3 = sut3.reqwest {url :'foo'}
      actual3.headers.should.not.have.property 'X-HTTP-Method'


  describe 'angularJS REST request object creator', ->

    it 'should return an object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      sut.angularJS().should.be.an 'object'

    it 'should call getRequestProperties on properties object if method is present (AddOnIntegration)', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      fakeRequestProperties =
        url : 'search/suggest'
        getRequestProperties: () =>

      spy = sinon.spy fakeRequestProperties, 'getRequestProperties'
      actual = sut.angularJS fakeRequestProperties
      spy.calledOnce.should.be.true
      fakeRequestProperties.getRequestProperties.restore()

    it 'should contain passed url combined with AppWeb API endpoint as url property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS {url: 'web/title'}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal 'https://dotnetrocks.sharepoint.com/_api/web/title'

    it 'should contain correct url for HostWeb access if hostWebUrl is given', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS {url: 'web/title', hostWebUrl: ShareCoffee.Commons.getHostWebUrl()}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppContextSite(@target)/web/title?@target='https://foo.sharepoint.com/sites/dev'"

    it 'should contain correct url for HostWeb access if hostWebUrl is given and already a parameter in url exists', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS {url: 'web/?$Select=Title', hostWebUrl: ShareCoffee.Commons.getHostWebUrl()}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppContextSite(@target)/web/?$Select=Title&@target='https://foo.sharepoint.com/sites/dev'"

    it 'should provide HttpMethod as method property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS {url: 'foo'}
      actual.should.have.property 'method'
      actual.method.should.be.an 'string'
      actual.method.should.equal 'GET'

    it 'should provide a headers object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS {url: 'foo'}
      actual.should.have.property 'headers'
      actual.headers.should.be.an 'object'

    it 'should provide a Accept property within headers object containing current applicationType as string value', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS {url: 'foo'}
      actual.headers.should.have.property 'Accept'
      actual.headers.Accept.should.be.an 'string'
      actual.headers.Accept.should.equal ShareCoffee.REST.applicationType

    it 'should provide a Content-Type property within headers object containing current applicationType if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.angularJS {url: 'foo'}
      actual.headers.should.have.property 'Content-Type'
      actual.headers['Content-Type'].should.be.an 'string'
      actual.headers['Content-Type'].should.equal ShareCoffee.REST.applicationType

    it 'should not provide a Content-Type property within headers if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS {url: 'foo'}
      actual.headers.should.not.have.property 'Content-Type'

    it 'should provide the X-RequestDigest property on headers if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.angularJS {url: 'foo'}
      actual.headers.should.have.property 'X-RequestDigest'
      actual.headers['X-RequestDigest'].should.be.an 'string'
      actual.headers['X-RequestDigest'].should.equal '1234567890'

    it 'should not provide a headers.X-RequestDigest proeprty if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS {url: 'foo'}
      actual.headers.should.not.have.property 'X-RequestDigest'

    it 'should provide payload as data property if method is POST', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = "{'a': 'b'}"
      actual = sut.angularJS {url: 'foo', payload: payload}
      actual.should.have.property 'data'
      actual.data.should.equal payload

    it 'should not provide a data property if method is not POST', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      payload = "{'a': 'b'}"
      actual = sut.angularJS {url: 'foo', payload: payload}
      actual.should.not.have.property 'data'

    it 'should stringify the payload if it is not given as string', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload =
        name: 'foo'
      expected = JSON.stringify payload
      actual = sut.angularJS {url: 'foo', payload: payload}
      actual.data.should.equal expected

    it 'should stringify the payload using angular when available if it is not given as string', ->
      payload =
        name: 'foo'
      root.angular = toJson: sinon.stub().withArgs(payload).returns("angular serialized")
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.angularJS {url: 'foo', payload: payload}
      actual.data.should.equal "angular serialized"

    it 'should provide a If-Match property with value * if mathod is DELETE', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.angularJS {url: 'foo'}
      actual.headers.should.have.property 'If-Match'
      actual.headers['If-Match'].should.be.an 'string'
      actual.headers['If-Match'].should.equal '*'

    it 'should not provide an If-Match property if method is not DELETE expecting etag is passed and method is POST', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.angularJS {url : 'foo' }
      actual.headers.should.not.have.property 'If-Match'

      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.angularJS {url: 'foo', payload: 'data', eTag: 'etag'}
      actual2.headers.should.have.property 'If-Match'
      actual2.headers['If-Match'].should.equal 'etag'

      sut3 = new ShareCoffee.RESTFactory 'POST'
      actual3 = sut3.angularJS {url: 'foo', payload: 'data'}
      actual3.headers.should.not.have.property 'If-Match'

    it 'should set eTag to * if update query is created and no eTag passed', ->
      sut = new ShareCoffee.RESTFactory('POST',true)
      actual = sut.angularJS {url: 'foo'}
      actual.headers['If-Match'].should.equal '*'

    it 'should provide a X-HTTP-Method header property with value MERGE only if method is POST and etag is given', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.angularJS {url: 'foo', payload: 'data', eTag: 'etag'}
      actual.headers.should.have.property 'X-HTTP-Method'
      actual.headers['X-HTTP-Method'].should.be.an 'string'
      actual.headers['X-HTTP-Method'].should.equal 'MERGE'

    it 'should not have an X-HTTP-Method header property if method is not POST and etag is not given', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.angularJS { url: 'foo' }
      actual.headers.should.not.have.property 'X-HTTP-Method'
      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.angularJS {url: 'foo' }
      actual2.headers.should.not.have.property 'X-HTTP-Method'
      sut3 = new ShareCoffee.RESTFactory 'GET'
      actual3 = sut3.angularJS { url: 'foo'}
      actual3.headers.should.not.have.property 'X-HTTP-Method'

  describe 'jQuery REST request object creator', ->

    it 'should return an object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      sut.jQuery().should.be.an 'object'

    it 'should call getRequestProperties on properties object if method is present (AddOnIntegration)', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      fakeRequestProperties =
        url : 'search/suggest'
        getRequestProperties: () =>

      spy = sinon.spy fakeRequestProperties, 'getRequestProperties'
      actual = sut.jQuery fakeRequestProperties
      spy.calledOnce.should.be.true
      fakeRequestProperties.getRequestProperties.restore()

    it 'should contain passed url combined with AppWeb API endpoint as url property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery {url: 'web/title'}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal 'https://dotnetrocks.sharepoint.com/_api/web/title'

    it 'should contain correct url for HostWeb access if hostWebUrl is given', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery {url: 'web/title', hostWebUrl: ShareCoffee.Commons.getHostWebUrl()}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppContextSite(@target)/web/title?@target='https://foo.sharepoint.com/sites/dev'"

    it 'should contain correct url for HostWeb access if hostWebUrl is given and already a parameter in url exists', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery {url: 'web/?$Select=Title', hostWebUrl: ShareCoffee.Commons.getHostWebUrl()}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppContextSite(@target)/web/?$Select=Title&@target='https://foo.sharepoint.com/sites/dev'"

    it 'should provide HttpMethod as type property of type string', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery {url: 'foo'}
      actual.should.have.property 'type'
      actual.type.should.be.an 'string'
      actual.type.should.equal 'GET'

    it 'should provide a headers object', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery {url: 'foo'}
      actual.should.have.property 'headers'
      actual.headers.should.be.an 'object'

    it 'should provide a Accept property within headers object containing current applicationType as string value', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery {url: 'foo'}
      actual.headers.should.have.property 'Accept'
      actual.headers.Accept.should.be.an 'string'
      actual.headers.Accept.should.equal ShareCoffee.REST.applicationType

    it 'should provide a contentType property if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.jQuery {url: 'foo'}
      actual.should.have.property 'contentType'
      actual.contentType.should.be.an 'string'
      actual.contentType.should.equal ShareCoffee.REST.applicationType

    it 'should not provide a contentType property if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery {url: 'foo'}
      actual.should.not.have.property 'contentType'

    it 'should provide the X-RequestDigest property on headers if method is not GET', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.jQuery {url: 'foo'}
      actual.headers.should.have.property 'X-RequestDigest'
      actual.headers['X-RequestDigest'].should.be.an 'string'
      actual.headers['X-RequestDigest'].should.equal '1234567890'

    it 'should not provide a headers.X-RequestDigest proeprty if method is GET', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery {url: 'foo'}
      actual.headers.should.not.have.property 'X-RequestDigest'

    it 'should provide payload as data property if method is POST', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload = "{'a': 'b'}"
      actual = sut.jQuery {url: 'foo', payload:payload}
      actual.should.have.property 'data'
      actual.data.should.equal payload

    it 'should not provide a data property if method is not POST', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      payload = "{'a': 'b'}"
      actual = sut.jQuery {url: 'foo', payload: payload}
      actual.should.not.have.property 'data'

    it 'should stringify the payload if it is not given as string', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      payload =
        name: 'foo'
      expected = JSON.stringify payload
      actual = sut.jQuery {url: 'foo', payload: payload}
      actual.data.should.equal expected

    it 'should provide a If-Match property with value * if mathod is DELETE', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.jQuery {url: 'foo'}
      actual.headers.should.have.property 'If-Match'
      actual.headers['If-Match'].should.be.an 'string'
      actual.headers['If-Match'].should.equal '*'

    it 'should not provide an If-Match property if method is not DELETE expecting etag is passed and method is POST', ->
      sut = new ShareCoffee.RESTFactory 'GET'
      actual = sut.jQuery {url: 'foo'}
      actual.headers.should.not.have.property 'If-Match'

      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.jQuery {url: 'foo', payload: 'data', eTag: 'etag'}
      actual2.headers.should.have.property 'If-Match'
      actual2.headers['If-Match'].should.equal 'etag'

      sut3 = new ShareCoffee.RESTFactory 'POST'
      actual3 = sut3.jQuery {url: 'foo', payload: 'data'}
      actual3.headers.should.not.have.property 'If-Match'

    it 'should set eTag to * if update query is created and no eTag passed', ->
      sut = new ShareCoffee.RESTFactory('POST',true)
      actual = sut.jQuery {url: 'foo'}
      actual.headers['If-Match'].should.equal '*'

    it 'should provide a X-HTTP-Method header property with value MERGE only if method is POST and etag is given', ->
      sut = new ShareCoffee.RESTFactory 'POST'
      actual = sut.jQuery {url: 'foo', payload: 'data', eTag: 'etag'}
      actual.headers.should.have.property 'X-HTTP-Method'
      actual.headers['X-HTTP-Method'].should.be.an 'string'
      actual.headers['X-HTTP-Method'].should.equal 'MERGE'

    it 'should not have an X-HTTP-Method header property if method is not POST and etag is not given', ->
      sut = new ShareCoffee.RESTFactory 'DELETE'
      actual = sut.jQuery {url: 'foo'}
      actual.headers.should.not.have.property 'X-HTTP-Method'
      sut2 = new ShareCoffee.RESTFactory 'POST'
      actual2 = sut2.jQuery {url: 'foo'}
      actual2.headers.should.not.have.property 'X-HTTP-Method'
      sut3 = new ShareCoffee.RESTFactory 'GET'
      actual3 = sut3.jQuery {url: 'foo'}
      actual3.headers.should.not.have.property 'X-HTTP-Method'

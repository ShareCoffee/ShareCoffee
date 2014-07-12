chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.CrossDomain'

root = global ? window

describe 'ShareCoffee.CrossDomain', ->  
  
  beforeEach () ->
    ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
    root.document = { URL: 'http://dotnetrocks.sharepoint.com/Default.aspx?Foo=Bar&?SPHostUrl=', getElementById : ()-> } 
    root.ShareCoffee.Commons = 
      getHostWebUrl: ()->
        "https://foo.sharepoint.com/sites/dev"
      getAppWebUrl: ()->
        "https://foo.sharepoint.com/"
      getApiRootUrl: ()->
        "https://dotnetrocks.sharepoint.com/_api/"
      getFormDigest: ()->
        "1234567890"
    root.SP = 
      AppContextSite: (ctx, url)->
        get_web: ()->
          {}
      ClientContext: (appWebUrl)->
        set_webRequestExecutorFactory: (factory) -> 
          {}
      ProxyWebRequestExecutorFactory: (appWebUrl)->
        {}
        

  afterEach () ->
    delete root._spPageContextInfo 
    delete root.document 

  describe 'build', ->
    
    it 'should be available as object', ->
      ShareCoffee.CrossDomain.build.should.be.an 'object'

    it 'should provide build.read, build.update, build.delete, build.create as functions', ->
      ShareCoffee.CrossDomain.build.create.should.be.an 'object'
      ShareCoffee.CrossDomain.build.read.should.be.an 'object'
      ShareCoffee.CrossDomain.build.update.should.be.an 'object'
      ShareCoffee.CrossDomain.build.delete.should.be.an 'object'

    it 'should provide a configured object for all CRUD ops as object', ->
      forCreate = ShareCoffee.CrossDomain.build.create.for
      forRead = ShareCoffee.CrossDomain.build.read.for
      forUpdate = ShareCoffee.CrossDomain.build.update.for
      forDelete = ShareCoffee.CrossDomain.build.delete.for

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

  it 'should provide SPCrossDomainLib as single choice', ->

      ShareCoffee.CrossDomain.build.create.for.SPCrossDomainLib.should.be.an 'function'

  describe 'SharePoint CrossDomain Library REST request object creator', ->
    beforeEach ()->
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
    
    it 'should return an object', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      sut.SPCrossDomainLib().should.be.an 'object'
    
    it 'should throw an error if CrossDomainLibs are not loaded', ->
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = false
      (->ShareCoffee.CrossDomain.build.create.for.SPCrossDomainLib({url:'web/title'})).should.throw ''
      
    it 'should contain the required URL in RequestExecutors format as url property of type string', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual = sut.SPCrossDomainLib {url: 'web/title', hostWebUrl: ShareCoffee.Commons.getHostWebUrl()}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/SP.AppContextSite(@target)/web/title?@target='https://foo.sharepoint.com/sites/dev'"

    it 'should build an valid url for querying the AppWeb from Cloud-Hosted Apps', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual = sut.SPCrossDomainLib {url: 'web/title'}
      actual.should.have.property 'url'
      actual.url.should.be.an 'string'
      actual.url.should.equal "https://dotnetrocks.sharepoint.com/_api/web/title"

    it 'should provide HttpMethod as method property of type string', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual = sut.SPCrossDomainLib {url: 'foo'}
      actual.should.have.property 'method'
      actual.method.should.be.an 'string'
      actual.method.should.equal 'GET'

    it 'should set success handler if present', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      onSuccess = ()->
      actual = sut.SPCrossDomainLib {url: 'web/title', onSuccess: onSuccess}
      actual.should.have.property 'success'
      actual.success.should.be.an 'function'
      actual.success.should.equal onSuccess

    it 'should not set success handler if present', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual = sut.SPCrossDomainLib {url: 'web/title'}
      actual.should.not.have.property 'success'

    it 'should set error handler if present', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      onError = ()->
      actual = sut.SPCrossDomainLib {url: 'web/title', onError: onError}
      actual.should.have.property 'error'
      actual.error.should.be.an 'function'
      actual.error.should.equal onError

    it 'should not set error handler if present', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual = sut.SPCrossDomainLib {url: 'web/title'}
      actual.should.not.have.property 'error'
    
    it 'should provide a headers object', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual = sut.SPCrossDomainLib {url: 'foo'}
      actual.should.have.property 'headers'
      actual.headers.should.be.an 'object'
    
    it 'should provide a Accept property within headers object containing current applicationType as string value', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual = sut.SPCrossDomainLib {url: 'foo'}
      actual.headers.should.have.property 'Accept'
      actual.headers.Accept.should.be.an 'string'
      actual.headers.Accept.should.equal ShareCoffee.REST.applicationType

    it 'should not provide a headers.X-RequestDigest proeprty if method is GET', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual = sut.SPCrossDomainLib {url: 'foo'}
      actual.headers.should.not.have.property 'X-RequestDigest'

    it 'should provide a Content-Type property within headers object containing current applicationType if method is not GET', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'POST'
      actual = sut.SPCrossDomainLib {url: 'foo'}
      actual.headers.should.have.property 'Content-Type'
      actual.headers['Content-Type'].should.be.an 'string'
      actual.headers['Content-Type'].should.equal ShareCoffee.REST.applicationType

    it 'should not provide a Content-Type property within headers if method is GET', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual = sut.SPCrossDomainLib {url: 'foo'}
      actual.headers.should.not.have.property 'Content-Type'

    it 'should provide a If-Match property with value * if mathod is DELETE', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'DELETE'
      actual = sut.SPCrossDomainLib {url : 'foo'}
      actual.headers.should.have.property 'If-Match'
      actual.headers['If-Match'].should.be.an 'string'
      actual.headers['If-Match'].should.equal '*'

    it 'should not provide an If-Match property if method is not DELETE expecting etag is passed and method is POST', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual = sut.SPCrossDomainLib {url: 'foo'}
      actual.headers.should.not.have.property 'If-Match'

      sut2 = new ShareCoffee.CrossDomainRESTFactory 'POST'
      actual2 = sut2.SPCrossDomainLib {url: 'foo', payload: '{"data":"foo"}', eTag: 'etag'}
      actual2.headers.should.have.property 'If-Match'
      actual2.headers['If-Match'].should.equal 'etag'

      sut3 = new ShareCoffee.CrossDomainRESTFactory 'POST'
      actual3 = sut3.SPCrossDomainLib {url: 'foo', payload: '{"d":"data"}'}
      actual3.headers.should.not.have.property 'If-Match'

    it 'should provide a X-HTTP-Method header property with value MERGE only if method is POST and etag is given', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'POST'
      actual = sut.SPCrossDomainLib {url: 'foo', payload: '{"d":"data"}', eTag: 'etag'}
      actual.headers.should.have.property 'X-HTTP-Method'
      actual.headers['X-HTTP-Method'].should.be.an 'string'
      actual.headers['X-HTTP-Method'].should.equal 'MERGE'

    it 'should not have an X-HTTP-Method header property if method is not POST and etag is not given', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'DELETE'
      actual = sut.SPCrossDomainLib {url: 'foo'}
      actual.headers.should.not.have.property 'X-HTTP-Method'
      sut2 = new ShareCoffee.CrossDomainRESTFactory 'POST'
      actual2 = sut2.SPCrossDomainLib {url: 'foo'}
      actual2.headers.should.not.have.property 'X-HTTP-Method'
      sut3 = new ShareCoffee.CrossDomainRESTFactory 'GET'
      actual3 = sut3.SPCrossDomainLib {url: 'foo'}
      actual3.headers.should.not.have.property 'X-HTTP-Method'

    it 'should provide payload as body property if method is POST', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'POST'
      payload = "{'a': 'b'}"
      actual = sut.SPCrossDomainLib {url: 'foo', payload: payload }
      actual.should.have.property 'body'
      actual.body.should.equal payload

    it 'should not provide a body property if method is not POST', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'DELETE'
      payload = "{'a': 'b'}"
      actual = sut.SPCrossDomainLib {url: 'foo', payload: payload }
      actual.should.not.have.property 'body'

    it 'should stringify the payload if it is not given as string', ->
      sut = new ShareCoffee.CrossDomainRESTFactory 'POST'
      payload = 
        name: 'foo'
      expected = JSON.stringify payload
      actual = sut.SPCrossDomainLib { url: 'foo', payload: payload}
      actual.body.should.equal expected

  describe 'loadCrossDomainLibrary', ->

    beforeEach () ->
      root.ShareCoffee.Core = 
        loadScript: (url, onSuccess,onError) ->
          onSuccess() if onSuccess

    afterEach () ->
      delete root.ShareCoffee.Core

    it 'should call loadScript on ShareCoffee.Core once for REST ', ->
      spy = sinon.spy ShareCoffee.Core, 'loadScript'
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = false 
      ShareCoffee.CrossDomain.loadCrossDomainLibrary null, null
      spy.calledOnce.should.be.ok
      spy.restore()

    it 'should fire onSuccess when loadScript succeeded', ->
      loadScriptStub = sinon.stub ShareCoffee.Core, 'loadScript', (url, s,e) ->
        s() if s
      onSuccess = sinon.spy()
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = false 
      ShareCoffee.CrossDomain.loadCrossDomainLibrary onSuccess, null
      onSuccess.calledOnce.should.be.true
      loadScriptStub.restore()

    it 'should fire onError when loadScript failes', ->
      loadScriptStub = sinon.stub ShareCoffee.Core, 'loadScript', (url, s,e) ->
        e() if e
      onError = sinon.spy()
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = false
      ShareCoffee.CrossDomain.loadCrossDomainLibrary null, onError
      onError.calledOnce.should.be.true
      loadScriptStub.restore()
    
    it 'should set crossDomainLibrariesLoaded to true if everything succeeded', ->
      loadScriptStub = sinon.stub ShareCoffee.Core, 'loadScript', (url, s,e) ->
        s() if s
      onSuccess = sinon.spy()
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = false 
      ShareCoffee.CrossDomain.loadCrossDomainLibrary onSuccess, null
      onSuccess.calledOnce.should.be.true
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded.should.be.true
      loadScriptStub.restore()

    it 'should set crossDomainLibrariesLoaded to false if any error occurs', ->
      loadScriptStub = sinon.stub ShareCoffee.Core, 'loadScript', (url, s,e) ->
        e() if e
      onError = sinon.spy()
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = false 
      ShareCoffee.CrossDomain.loadCrossDomainLibrary null, onError
      onError.calledOnce.should.be.true
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded.should.be.false
      loadScriptStub.restore()

  describe 'getClientContext', ->

    it 'should be available as function', ->
      ShareCoffee.CrossDomain.getClientContext.should.be.an 'function'

    it 'should return an object if libraries loaded', ->
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
      actual = ShareCoffee.CrossDomain.getClientContext()
      actual.should.be.an 'object'

    it 'should throw an error if cross-domain-scripts are not loaded', ->
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded=false
      (->ShareCoffee.CrossDomain.getClientContext()).should.throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the ClientCotext'

    it 'should call getAppWebUrl in order to determine the correct AppWebUrl', ->
      getAppWebUrlStub = sinon.stub ShareCoffee.Commons, 'getAppWebUrl', () ->
        return 'https://appweburl'

      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
      ShareCoffee.CrossDomain.getClientContext()
      getAppWebUrlStub.calledOnce.should.be.true
      getAppWebUrlStub.restore()

    it 'should call SP.ClientContext constructor and pass AppWebUrl', ->
      
      spy = sinon.spy SP, 'ClientContext'
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
      ShareCoffee.CrossDomain.getClientContext()
      spy.calledWithExactly('https://foo.sharepoint.com/').should.be.true
      spy.restore()

    it 'should call ProxyWebRequestExecutorFactory constructor and pass AppWebUrl', ->

      spy = sinon.spy SP, 'ProxyWebRequestExecutorFactory'
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
      ShareCoffee.CrossDomain.getClientContext()
      spy.calledWithExactly('https://foo.sharepoint.com/').should.be.true
      spy.restore()

    it 'should call set_webRequestExecutorFactory on context instance and pass the factory', ->
      
      actualFactory = null;
      expected = 
        foo: 'bar'

      fStub = sinon.stub SP, 'ProxyWebRequestExecutorFactory', (appWebUrl) ->
        return expected
      ctxStub = sinon.stub SP, 'ClientContext', (url)=>
        return { set_webRequestExecutorFactory: (factory) =>
          actualFactory = factory}
  
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
      ShareCoffee.CrossDomain.getClientContext()
      actualFactory.should.equal expected

  describe 'getHostWeb', ->

    it 'should be available as function', ->
      ShareCoffee.CrossDomain.getHostWeb.should.be.an 'function'
  
    it 'should return an object if libraries loaded', ->
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
      ctx = new SP.ClientContext ""
      actual = ShareCoffee.CrossDomain.getHostWeb ctx
      actual.should.be.an 'object'
    
    it 'should throw an error if passed context is null', ->
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded = true
      (->actual = ShareCoffee.CrossDomain.getHostWeb(null)).should.throw 'ClientContext cant be null, call ShareCoffee.CrossDomain.getClientContext() first'

    it 'should throw an error if cross-domain-scripts are not loaded', ->
      ShareCoffee.CrossDomain.crossDomainLibrariesLoaded=false
      (->ShareCoffee.CrossDomain.getHostWeb("")).should.throw 'Cross Domain Libraries not loaded, call ShareCoffee.CrossDomain.loadCrossDomainLibrary() before acting with the ClientCotext'


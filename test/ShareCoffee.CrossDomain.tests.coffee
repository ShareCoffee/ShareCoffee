chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.CrossDomain'

root = global ? window

describe 'ShareCoffee.CrossDomain', ->  
  
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
      ShareCoffee.CrossDomain.loadCrossDomainLibrary null, null
      spy.calledWithExactly('https://foo.sharepoint.com/sites/dev/_layouts/15/SP.RequestExecutor.js', null, null).should.be.ok
      spy.restore()

    it 'should fire onSuccess when loadScript succeeded', ->
      loadScriptStub = sinon.stub ShareCoffee.Core, 'loadScript', (url, s,e) ->
        s() if s
      onSuccess = sinon.spy()
      ShareCoffee.CrossDomain.loadCrossDomainLibrary onSuccess, null
      onSuccess.calledOnce.should.be.true
      loadScriptStub.restore()

    it 'should fire onError when loadScript failes', ->
      loadScriptStub = sinon.stub ShareCoffee.Core, 'loadScript', (url, s,e) ->
        e() if e
      onError = sinon.spy()
      ShareCoffee.CrossDomain.loadCrossDomainLibrary null, onError
      onError.calledOnce.should.be.true
      loadScriptStub.restore()


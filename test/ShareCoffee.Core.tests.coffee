chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.Core'
describe 'ShareCoffee.Core', ->

  describe 'checkConditions', ->
    it 'should not throw an error if all values are defined or not null',->
      (->ShareCoffee.Core.checkConditions('e',1,2,3,4,5,6,7,'','asd',{},[])).should.not.throw 'e'
    it 'should throw an error if any of the passed objects is undefined or null', ->
      (->ShareCoffee.Core.checkConditions('e', [], {}, [], {}, undefined)).should.throw 'e'
      (->ShareCoffee.Core.checkConditions('e', {},[],{},null,{})).should.throw 'e'
      (->ShareCoffee.Core.checkConditions('e', null)).should.throw 'e'
      (->ShareCoffee.Core.checkConditions('e', undefined)).should.throw 'e'
      (->ShareCoffee.Core.checkConditions('e', {},null,[],undefined, {})).should.throw 'e'

  describe 'loadScript', ->

    it 'should load documents head tag, call createElement on document instance and call appendChild on head', ->
      root = global ? window
      root.FakeTag =
        appendChild: (el) ->
      root.document = 
        createElement: (tag) ->
          {}
        getElementsByTagName: (tag) ->
          item : (index) ->
            root.FakeTag

      spyGetElementsByTagName = sinon.spy document, 'getElementsByTagName'
      spyCreateElement = sinon.spy document, 'createElement'
      spyAppendChild = sinon.spy FakeTag, 'appendChild'

      actual = { readyState: 4, status:  200, onReadyStateChange: null, responseText: 'foobar'}
      expected = {language: 'javascript', type: 'text/javascript', defer: true, text: 'foobar'}
      stub = sinon.stub ShareCoffee.Core, 'getRequestInstance'
      stub.returns actual
      ShareCoffee.Core.loadScript '' 
    
      actual.onReadyStateChange()
      spyGetElementsByTagName.calledWithExactly('head').should.be.ok
      spyCreateElement.calledWithExactly('script').should.be.ok
      spyAppendChild.calledWithExactly(expected).should.be.ok

      spyGetElementsByTagName.restore()
      spyCreateElement.restore()

      ShareCoffee.Core.getRequestInstance.restore()

    it 'should call onError when ReadyState 6 and HttpStatusCode not 200 or not 304', ->
      actual = { readyState: 4, status:  400, onReadyStateChange: null }
      stub = sinon.stub ShareCoffee.Core, 'getRequestInstance'
      stub.returns actual
      spySuccess = sinon.spy()
      spyError = sinon.spy()
      ShareCoffee.Core.loadScript '', spySuccess, spyError
    
      actual.onReadyStateChange()
      actual.status = 501
      actual.onReadyStateChange()
      spySuccess.called.should.be.false
      spyError.calledTwice.should.be.true
      ShareCoffee.Core.getRequestInstance.restore()
      
    it 'should register onReadyStateChange callback on RequestObject', ->
      actual = { onReadyStateChange : null }
      stub = sinon.stub ShareCoffee.Core, 'getRequestInstance'
      stub.returns actual
      
      ShareCoffee.Core.loadScript '', null, null
      actual.onReadyStateChange.should.not.be.null

      ShareCoffee.Core.getRequestInstance.restore()
    
    it 'should neither call onLoaded nor onError when not in readyState 4', ->
      actual = { readyState: 3, onReadyStateChange: null }
      stub = sinon.stub ShareCoffee.Core, 'getRequestInstance'
      stub.returns actual
      spySuccess = sinon.spy()
      spyError = sinon.spy()
      ShareCoffee.Core.loadScript '', spySuccess, spyError
      actual.onReadyStateChange()
      spySuccess.called.should.be.false
      spyError.called.should.be.false
      ShareCoffee.Core.getRequestInstance.restore()

  describe 'getRequestInstance', ->
    
    it 'should return a XmlHttRequest instance if XMLHttpRequest is present',->
      root = global ? window
      root.XMLHttpRequest = ()->
      if XMLHttpRequest?
        instance = ShareCoffee.Core.getRequestInstance()
        instance.should.be.instanceOf(XMLHttpRequest)
      else
        console.log "No XMLHttpRequest present"
      delete root.XMLHttpRequest

    it 'should return a ActiveXObject instance if ActiveXObject is present', ->
      root = global ? window
      root.ActiveXObject = () ->
      if ActiveXObject?
        instance = ShareCoffee.Core.getRequestInstance()
        instance.should.be.instanceOf(ActiveXObject)
      else
        console.log "No ActiveXObject present"
      delete root.ActiveXObject

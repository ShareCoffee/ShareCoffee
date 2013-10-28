chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.Core'

root = global ? window

describe 'ShareCoffee.Core', ->

  describe 'checkConditions', ->

    it 'should not throw an error if raise condition returns false', ->
      condition = ()->
        true
      (->ShareCoffee.Core.checkConditions('e',condition)).should.not.throw 'e'

    it 'should throw an error and write it to the error console if raise condition returns true', -> 
      spy = sinon.spy console, 'error'
      condition = () ->
        false
      (->ShareCoffee.Core.checkConditions('e', condition)).should.throw 'e'
      spy.calledWithExactly('e')
      spy.restore()

  describe 'loadScript', ->
    beforeEach () ->
      root.FakeTag =
        appendChild: (el) ->
      root.document = 
        createElement: (tag) ->
          {}
        getElementsByTagName: (tag) ->
          item : (index) ->
            root.FakeTag

    afterEach () ->
      delete root.FakeTag
      delete root.document

    it 'should load documents head tag, call createElement on document instance and call appendChild on head', ->
  
      spyGetElementsByTagName = sinon.spy document, 'getElementsByTagName'
      spyCreateElement = sinon.spy document, 'createElement'
      spyAppendChild = sinon.spy FakeTag, 'appendChild'
      ShareCoffee.Core.loadScript '' 
      spyGetElementsByTagName.calledWithExactly('head').should.be.ok
      spyCreateElement.calledWithExactly('script').should.be.ok
      spyAppendChild.called.should.be.true

      spyGetElementsByTagName.restore()
      spyCreateElement.restore()
      spyAppendChild.restore()

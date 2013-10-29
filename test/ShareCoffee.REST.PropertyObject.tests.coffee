chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.REST'

root = global ? window

describe 'ShareCoffee.REST.angularProperties', ->

  it 'should be an constructor function', ->
    ShareCoffee.REST.should.have.property 'angularProperties'
    ShareCoffee.REST.angularProperties.should.be.an 'function'

  it 'should have required properties', ->
    sut = new ShareCoffee.REST.angularProperties()
    sut.should.have.property 'url'
    sut.should.have.property 'payload'
    sut.should.have.property 'hostWebUrl'
    sut.should.have.property 'eTag'

describe 'ShareCoffee.REST.jQueryProperties', ->
  
  it 'should be a constructor function', ->
    ShareCoffee.REST.should.have.property 'jQueryProperties'
    ShareCoffee.REST.jQueryProperties.should.be.an 'function'

  it 'should have required properties', ->
    sut = new ShareCoffee.REST.jQueryProperties()
    sut.should.have.property 'url'
    sut.should.have.property 'payload'
    sut.should.have.property 'hostWebUrl'
    sut.should.have.property 'eTag'

  
describe 'ShareCoffee.REST.reqwestProperties', ->
  
  it 'should be a constructor function', ->
    ShareCoffee.REST.should.have.property 'reqwestProperties'
    ShareCoffee.REST.reqwestProperties.should.be.an 'function'

  it 'should have required properties', ->
    sut = new ShareCoffee.REST.reqwestProperties()
    sut.should.have.property 'url'
    sut.should.have.property 'payload'
    sut.should.have.property 'hostWebUrl'
    sut.should.have.property 'eTag'
    sut.should.have.property 'onSuccess'
    sut.should.have.property 'onError'

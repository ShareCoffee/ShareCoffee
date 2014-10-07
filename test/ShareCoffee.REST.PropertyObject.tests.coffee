chai = require 'chai'
sinon = require 'sinon'
chai.should()

require '../src/ShareCoffee.Rest'

root = global ? window

describe 'ShareCoffee.REST.RequestProperties', ->

  it 'should be an constructor function', ->
    ShareCoffee.REST.should.have.property 'RequestProperties'
    ShareCoffee.REST.RequestProperties.should.be.an 'function'

  it 'should have required properties', ->
    sut = new ShareCoffee.REST.RequestProperties()
    sut.should.have.property 'url'
    sut.should.have.property 'payload'
    sut.should.have.property 'hostWebUrl'
    sut.should.have.property 'eTag'
    sut.should.have.property 'onSuccess'
    sut.should.have.property 'onError'

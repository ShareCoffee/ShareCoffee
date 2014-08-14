chai = require 'chai'
sinon = require 'sinon'
chai.should()

root = global ? window

require '../src/ShareCoffee.Core'

describe 'ShareCoffee', ->

    it 'should expose jsonRequestBehavior as property', ->
        ShareCoffee.should.have.property 'jsonRequestBehavior'
        ShareCoffee.jsonRequestBehavior.should.be.an 'string'
describe 'ShareCoffee.JSONLight Support', ->
    beforeEach () ->
      ShareCoffee.jsonRequestBehavior = ShareCoffee.JsonRequestBehaviors.default
      
    it 'should provide verbose mode as default', ->
        actual = ShareCoffee.jsonRequestBehavior
        actual.should.be.an 'string'
        actual.should.equal 'application/json;odata=verbose'

    it 'should expose JsonRequestBehaviors as object', ->
        ShareCoffee.should.have.property 'JsonRequestBehaviors'
        ShareCoffee.JsonRequestBehaviors.should.be.an 'object'

    it 'should expose all available behaviors as property', ->
        ShareCoffee.JsonRequestBehaviors.should.have.property 'default'
        ShareCoffee.JsonRequestBehaviors.default.should.equal 'application/json;odata=verbose'

        ShareCoffee.JsonRequestBehaviors.should.have.property 'verbose'
        ShareCoffee.JsonRequestBehaviors.verbose.should.equal 'application/json;odata=verbose'

        ShareCoffee.JsonRequestBehaviors.should.have.property 'minimal'
        ShareCoffee.JsonRequestBehaviors.minimal.should.equal 'application/json;odata=minimalmetadata'

        ShareCoffee.JsonRequestBehaviors.should.have.property 'nometadata'
        ShareCoffee.JsonRequestBehaviors.nometadata.should.equal 'application/json;odata=nometadata'



chai = require 'chai'
sinon = require 'sinon'
chai.should()

root = global ? window

require '../src/ShareCoffee.Core'

describe 'ShareCoffee.Core', ->

	it 'should expose ShareCoffee as $s', ->
		root.should.have.property '$s'
		root.$s.should.be.an 'object'
		root.$s.should.equal root.ShareCoffee




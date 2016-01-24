chai = require 'chai'
sinon = require 'sinon'
expect = chai.expect

chai.use require 'sinon-chai'

Canvas = require("../mithril-canvas.js")
  ios:    false
  ff:     false
  old:    false
  chrome: false

describe "test first", ()->
  it "spec spec", ->
    expect ->
      throw "Error"
    .to.throw("Error")

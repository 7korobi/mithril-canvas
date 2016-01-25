Canvas = require("../mithril-canvas.min.js")
  ios:    false
  ff:     false
  old:    false
  chrome: false

describe "test first", ()->
  it "spec spec", ->
    expect ->
      throw "Error"
    .to.throw("Error")

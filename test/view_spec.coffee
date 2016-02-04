CanvasFactory = require("../mithril-canvas.min.js")
Canvas = CanvasFactory
  ios:    false
  ff:     false
  old:    false
  chrome: false

describe "customize for", ->
  it "old chrome", ->
    canvas = CanvasFactory(chrome: true, old: true)
    expect( canvas ).to.have.property "view"
    expect( canvas ).to.have.property "controller"

  it "chrome", ->
    canvas = CanvasFactory(chrome: true)
    expect( canvas ).to.have.property "view"
    expect( canvas ).to.have.property "controller"

  it "firefox", ->
    canvas = CanvasFactory(ff: true)
    expect( canvas ).to.have.property "view"
    expect( canvas ).to.have.property "controller"

  it "ios", ->
    canvas = CanvasFactory(ios: true)
    expect( canvas ).to.have.property "view"
    expect( canvas ).to.have.property "controller"


describe "view", ->
  it "use module", ->
    data_cache = {}
    canvas = ({size: [width, height], foo})->
      expect(  width ).to.eq 800
      expect( height ).to.eq 600
      expect( foo[0] ).to.eq -10
      expect( foo[1] ).to.eq  10

      config: (canvas, is_continue, context)->
        expect( context.test ).to.eq true
        # not to do
      data: ->
        data_cache
      background: ({ctx})->
        # not to do
      draw: ({state, ctx, offsets, is_touch, event: {clientX, clientY, screenX, screenY, touches}})->
        expect( state ).to.eq "boot"
        # not to do
      onmove: ({state, ctx, offsets, is_touch, event: {clientX, clientY, screenX, screenY, touches}})->
        expect( state ).to.eq "boot"
        # not to do

    c = new Canvas.controller "#head", canvas,
      size: [800, 600]
      foo: [-10,  10]
    expect( c.canvas_attr.width ).to.eq 800
    expect( c.canvas_attr.height ).to.eq 600
    expect( c.canvas_attr.style ).to.eq "width: 400px; height: 300px;"
    c.canvas_attr.config
      getContext: (type)->
        expect( type ).to.eq "2d"
        getImageData: ->
          "TEST_IMAGE"
    , false,
      test: true
    expect( data_cache.canvas ).to.have.property "800x600"
    expect( data_cache.canvas["800x600"] ).to.eq "TEST_IMAGE"

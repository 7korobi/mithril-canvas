calc_touch_A = ({pageX, pageY}, {left, top})->
  x = 2 * (pageX - left - window.scrollX)
  y = 2 * (pageY - top  - window.scrollY)
  {x, y}

calc_touch_B = ({pageX, pageY}, {left, top})->
  x = 2 * (pageX - left)
  y = 2 * (pageY - top  - window.scrollY)
  {x, y}

module.exports = (browser)->
  if browser.ios || browser.ff || browser.old && browser.chrome
    calc.touch = calc_touch_A
  else
    calc.touch = calc_touch_B

  Canvas

calc =
  touch: calc_touch_B

  mouse: (event)->
    x = event.offsetX || event.layerX # PC || firefox
    y = event.offsetY || event.layerY # PC || firefox
    if x? && y?
      x *= 2
      y *= 2
      {x, y}

  offsets: (e, elem, o)->
    o.offset = null
    o.offsets = []
    return unless e? && elem?
    if e.touches?
      rect = elem.getBoundingClientRect()
      o.offsets = for touch in e.touches
        calc.touch(touch, rect) # touch device
      o.offset = o.offsets[0] if 1 == e.touches.length
    else
      o.offset = calc.mouse(e) # mouse interface.
      o.offsets = [o.offset] if o.offset?

  offset: (e, elem)->
    return null unless e? && elem?

    if e.touches?
      rect = elem.getBoundingClientRect()
      calc.touch(e.touches[0], rect) # touch device
    else
      calc.mouse(e) # mouse interface.

present_functions = [
  "config"
  "data"
  "background"
  "draw"
  "onmove"
]

Canvas = (present)->
  controller: (attr, options)->
    {size: [width, height]} = options
    size = "#{width}x#{height}"
    canvas = null

    ctrl = new present(options)
    for func in present_functions
      ctrl[func] ?= ->

    args =
      state: "boot"
      is_touch: false
      offsets: []
      event: {}

    common = (event)->
      event.preventDefault()
      args.event = event
      ctrl.onmove args
      draw()

    start = (event)->
      args.state = "onstart"
      args.is_touch = true
      common event

    cancel = (event)->
      args.state = "oncancel"
      args.is_touch = false
      common event

    end = (event)->
      args.state = "onend"
      args.is_touch = false
      common event

    move = (event)->
      args.state = "onmove"
      calc.offsets event, canvas, args
      args.event = event
      common event

    do_background = ->
      {ctx} = args
      data = ctrl.data()

      if data
        data.canvas ?= {}
        # draw with background cache
        if image = data.canvas[size]
          ctx.putImageData image, 0, 0
          return
      ctrl.background args
      if data
        data.canvas[size] = ctx.getImageData 0, 0, width * 2, height * 2
    draw = ->
      do_background()
      ctrl.draw args

    config = (elem, is_continue, context)->
      unless args.ctx
        canvas = elem
        args.ctx = canvas.getContext "2d"

      ctrl.config canvas, is_continue, context
      ctrl.onmove args
      draw()

    @canvas_attr =
      width:  width
      height: height
      style: "width: #{width / 2}px; height: #{height / 2}px;"
      ontouchend: end
      ontouchmove: move
      ontouchstart: start
      ontouchcancel: cancel
      onmouseup:   end
      onmousemove: move
      onmousedown: start
      onmouseout:  end
      onmouseover: move
      config: config
    return

  view: (c, attr)->
    m "canvas#{attr}", c.canvas_attr

/**
 mithril-canvas - Mithril Canvas library
 @version v0.0.5
 @link https://github.com/7korobi/mithril-canvas
 @license 
**/


(function() {
  var Canvas, calc, calc_touch_A, calc_touch_B, present_functions;

  calc_touch_A = function(arg, arg1) {
    var left, pageX, pageY, top, x, y;
    pageX = arg.pageX, pageY = arg.pageY;
    left = arg1.left, top = arg1.top;
    x = 2 * (pageX - left - window.scrollX);
    y = 2 * (pageY - top - window.scrollY);
    return {
      x: x,
      y: y
    };
  };

  calc_touch_B = function(arg, arg1) {
    var left, pageX, pageY, top, x, y;
    pageX = arg.pageX, pageY = arg.pageY;
    left = arg1.left, top = arg1.top;
    x = 2 * (pageX - left);
    y = 2 * (pageY - top - window.scrollY);
    return {
      x: x,
      y: y
    };
  };

  module.exports = function(browser) {
    if (browser.ios || browser.ff || browser.old && browser.chrome) {
      calc.touch = calc_touch_A;
    } else {
      calc.touch = calc_touch_B;
    }
    return Canvas;
  };

  calc = {
    touch: calc_touch_B,
    mouse: function(event) {
      var x, y;
      x = event.offsetX || event.layerX;
      y = event.offsetY || event.layerY;
      if ((x != null) && (y != null)) {
        x *= 2;
        y *= 2;
        return {
          x: x,
          y: y
        };
      }
    },
    offsets: function(e, elem, o) {
      var rect, touch;
      o.offset = null;
      o.offsets = [];
      if (!((e != null) && (elem != null))) {
        return;
      }
      if (e.touches != null) {
        rect = elem.getBoundingClientRect();
        o.offsets = (function() {
          var i, len, ref, results;
          ref = e.touches;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            touch = ref[i];
            results.push(calc.touch(touch, rect));
          }
          return results;
        })();
        if (1 === e.touches.length) {
          return o.offset = o.offsets[0];
        }
      } else {
        o.offset = calc.mouse(e);
        if (o.offset != null) {
          return o.offsets = [o.offset];
        }
      }
    },
    offset: function(e, elem) {
      var rect;
      if (!((e != null) && (elem != null))) {
        return null;
      }
      if (e.touches != null) {
        rect = elem.getBoundingClientRect();
        return calc.touch(e.touches[0], rect);
      } else {
        return calc.mouse(e);
      }
    }
  };

  present_functions = ["config", "data", "background", "draw", "onmove"];

  Canvas = function(present) {
    return {
      controller: function(attr, options) {
        var args, cancel, canvas, common, config, ctrl, do_background, draw, end, func, height, i, len, move, ref, size, start, width;
        ref = options.size, width = ref[0], height = ref[1];
        size = width + "x" + height;
        canvas = null;
        ctrl = new present(options);
        for (i = 0, len = present_functions.length; i < len; i++) {
          func = present_functions[i];
          if (ctrl[func] == null) {
            ctrl[func] = function() {};
          }
        }
        args = {
          state: "boot",
          is_touch: false,
          offsets: [],
          event: {}
        };
        common = function(event) {
          event.preventDefault();
          args.event = event;
          ctrl.onmove(args);
          return draw();
        };
        start = function(event) {
          args.state = "onstart";
          args.is_touch = true;
          return common(event);
        };
        cancel = function(event) {
          args.state = "oncancel";
          args.is_touch = false;
          return common(event);
        };
        end = function(event) {
          args.state = "onend";
          args.is_touch = false;
          return common(event);
        };
        move = function(event) {
          args.state = "onmove";
          calc.offsets(event, canvas, args);
          args.event = event;
          return common(event);
        };
        do_background = function() {
          var ctx, data, image;
          ctx = args.ctx;
          data = ctrl.data();
          if (data) {
            if (data.canvas == null) {
              data.canvas = {};
            }
            if (image = data.canvas[size]) {
              ctx.putImageData(image, 0, 0);
              return;
            }
          }
          ctrl.background(args);
          if (data) {
            return data.canvas[size] = ctx.getImageData(0, 0, width * 2, height * 2);
          }
        };
        draw = function() {
          do_background();
          return ctrl.draw(args);
        };
        config = function(elem, is_continue, context) {
          if (!args.ctx) {
            canvas = elem;
            args.ctx = canvas.getContext("2d");
          }
          ctrl.config(canvas, is_continue, context);
          ctrl.onmove(args);
          return draw();
        };
        this.canvas_attr = {
          width: width,
          height: height,
          style: "width: " + (width / 2) + "px; height: " + (height / 2) + "px;",
          ontouchend: end,
          ontouchmove: move,
          ontouchstart: start,
          ontouchcancel: cancel,
          onmouseup: end,
          onmousemove: move,
          onmousedown: start,
          onmouseout: end,
          onmouseover: move,
          config: config
        };
      },
      view: function(c, attr) {
        return m("canvas" + attr, c.canvas_attr);
      }
    };
  };

}).call(this);

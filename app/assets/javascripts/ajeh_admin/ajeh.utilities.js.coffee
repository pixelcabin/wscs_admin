window.ajeh = {} unless window.ajeh?

window.ajeh._ =
  breaker:
    if typeof(StopIteration) is 'undefined' then '__break__' else StopIteration
  nativeForEach:
    Array.prototype.forEach
  each: (obj, iterator, context) ->
    try
      if this.nativeForEach and obj.forEach is this.nativeForEach
        obj.forEach iterator, context
      else if _.isNumber obj.length
        iterator.call context, obj[i], i, obj for i in [0...obj.length]
      else
        iterator.call context, val, key, obj  for own key, val of obj
    catch e
      throw e if e isnt this.breaker
    obj
  delay: (time, fn) ->
    setTimeout(fn, time)
  extend: (target, object) ->
    target[key] = value for key, value of object when !target[key]?
  randomInteger: (options={}) ->
    this.extend options,
      max: 1
      min: 0
    randomNumber = if options.min
      options.min + (Math.random() * (options.max - options.min))
    else
      Math.random() * options.max
    Math.round(randomNumber)
  backingScale: (context) ->
    if window.devicePixelRatio and window.devicePixelRatio > 1 and context.webkitBackingStorePixelRatio < 2
      return window.devicePixelRatio
    1
  rgb2hex: (rgb) ->
    rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/)
    hex = (x) -> ("0#{parseInt(x).toString(16)}").slice(-2)
    "##{hex(rgb[1])}#{hex(rgb[2])}#{hex(rgb[3])}"
  escapeRegExp: (string) ->
    string.replace(/([.*+?^${}()|[\]\/\\])/g, '\\$1')
  templateSettings: {
    start:        '<%'
    end:          '%>'
    interpolate:  /<%=(.+?)%>/g
  }
  template: (str, data) ->
    c = this.templateSettings
    endMatch = new RegExp("'(?=[^"+c.end.substr(0, 1)+"]*"+this.escapeRegExp(c.end)+")","g")
    fn = new Function 'obj',
      'var p=[],print=function(){p.push.apply(p,arguments);};' +
      'with(obj||{}){p.push(\'' +
      str.replace(/\r/g, '\\r')
         .replace(/\n/g, '\\n')
         .replace(/\t/g, '\\t')
         .replace(endMatch,"✄")
         .split("'").join("\\'")
         .split("✄").join("'")
         .replace(c.interpolate, "',$1,'")
         .split(c.start).join("');")
         .split(c.end).join("p.push('") +
         "');}return p.join('');"
    if data then fn(data) else fn

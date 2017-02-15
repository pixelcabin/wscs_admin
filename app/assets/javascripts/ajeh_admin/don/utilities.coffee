don._ = {}
don._.merge = (options, overrides) ->
  don._.extend (don._.extend {}, options), overrides
don._.extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object
don._.template = (html, data) ->
  _.template(html)(data)
don._.delay = (duration, fn) ->
  setTimeout(fn, duration)
don._.isUrl = (string) ->
  don.URL_REGEX.test(string)
don._.objectURL = (object) ->
  don.URL_API.createObjectURL(object)
don._.imageURL = (file) ->
  return null unless /image/.test(file.type)
  don._.objectURL(file)
don._.move = (element, array, direction) ->
  arrayLength = array.length
  fromIndex = array.indexOf(element)
  return if direction is 'up' and fromIndex is 0
  return if direction is 'down' and arrayLength is fromIndex+1
  if direction is 'up'
    toIndex = fromIndex - 1
  else if direction is 'down'
    toIndex = fromIndex + 1
  array.splice(toIndex, 0, array.splice(fromIndex, 1)[0])
don._.moveWithAnimation = (moveEl, options) ->
  duration = if options.duration? then options.duration else 200
  $moveEl = $(moveEl)
  direction = $moveEl.data('move')
  jqCurrent = $moveEl.parents(options.itemSelector)
  if direction is 'down'
    jqNext = jqCurrent.next(options.itemSelector)
    return if jqNext.length is 0
    offset = jqNext.offset().top - jqCurrent.offset().top
    jqCurrent.velocity translateY: [jqNext.outerHeight(), 0], duration
    jqNext.velocity translateY: [offset * -1, 0], duration, ->
      jqCurrent.insertAfter(jqNext)
      jqCurrent.removeAttr('style')
      jqNext.removeAttr('style')
  else if direction is 'up'
    jqPrevious = jqCurrent.prev(options.itemSelector)
    return if jqPrevious.length is 0
    offset = jqPrevious.offset().top - jqCurrent.offset().top
    jqCurrent.velocity translateY: [offset,0], duration
    jqPrevious.velocity translateY: [jqCurrent.outerHeight(),0], duration, ->
      jqCurrent.insertBefore(jqPrevious)
      jqCurrent.removeAttr('style')
      jqPrevious.removeAttr('style')
don._.stringHash = (string) ->
  hash = 0
  return hash if string.length is 0
  for i in [0..(string.length-1)]
    chr = string.charCodeAt(i)
    hash = ((hash << 5) - hash) + chr
    hash |= 0 # Convert to 32bit integer
  hash
don._.underscored = (string) ->
  string.replace(/([a-z\d])([A-Z]+)/g, '$1_$2').replace(/[-\s]+/g, '_').toLowerCase()

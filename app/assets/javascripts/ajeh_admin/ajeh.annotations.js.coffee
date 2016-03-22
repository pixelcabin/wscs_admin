window.ajeh = {} unless window.ajeh?

ajeh.delay = (ms, fnc) -> setTimeout(fnc, ms)

class ajeh.Annotatable
  constructor: (selector) ->
    @$el = $(selector)
    @el = @$el[0]
    @$el.data('annotatable', this)
    @$el.empty()
    @annotations = {}
    this._bindEvents()
  addAnnotations: (jsonString) ->
    console.log jsonString
    annotations = JSON.parse(jsonString)
    for id, annotationObject of annotations
      annotation = new ajeh.Annotation(this, @el)
      annotation.initWithObject(id, annotationObject)
      this._annotationAdded(annotation)
  removeAnnotation: (id) ->
    @annotations = _.omit(@annotations, id)
  toJSON: ->
    this._clean()
    output = {}
    for id, annotation of @annotations
      output[id] = annotation.toJSON()
    JSON.stringify output
  _clean: ->
    for id, annotation of @annotations
      continue unless annotation.isEmpty()
      annotation.remove()
      this.removeAnnotation(id)
  _annotationAdded: (annotation) ->
    @annotations[annotation.id] = annotation
  _bindEvents: ->
    @$el.on 'click', (e) =>
      annotation = new ajeh.Annotation(this, e.target)
      annotation.initWithClickEvent(e)
      this._annotationAdded(annotation)

      @$el.find('.active').removeClass('active')

class ajeh.Annotation
  constructor: (annotatable, el) ->
    @annotatable = annotatable
    @el = el
    @$el = $(el)
    @containerWidth = @$el.width()
    @halfContainerWidth = @containerWidth / 2
    @targetWidth = 36
    @halfTargetWidth = (@targetWidth / 2)
    @minSpaceRequired = 200
    # @minX = 0
    # @maxX = @containerWidth - @targetWidth
  initWithClickEvent: (e) ->
    @id = new Date().getTime()
    this._getClickPositionFromEvent(e)
    this.init()
    ajeh.delay 5, =>
      @$text.trigger('focus')
      @$annotation.addClass('active').siblings().removeClass('active')
  initWithObject: (id, object) ->
    @id = id
    @clickX = object.clickX
    @clickY = object.clickY
    @x = object.x
    @y = object.y
    @direction = object.direction
    this.init()
    @$text.val(object.text)
  init: ->
    this._initDomElements()
    this._initStyling()
    this._preventClickPropagation()
    this._refreshStyling()
  toJSON: ->
    clickX: @clickX
    clickY: @clickY
    x: @x
    y: @y
    text: @$text.val()
    direction: @direction
    width: @width
  isEmpty: ->
    @$text.val() is ''
  remove: ->
    @$annotation.remove()
  _getClickPositionFromEvent: (e) ->
    @originalClickX = e.pageX - @$el.offset().left
    @originalClickY = e.pageY - @$el.offset().top
    @clickX = @originalClickX - @halfTargetWidth
    @clickY = @originalClickY - @halfTargetWidth
    # throw 'oh fuck' if @clickX < @minX or @clickX > @maxX
    @direction = if @clickX > @halfContainerWidth then 'right' else 'left'
  _initDomElements: ->
    @$annotation = $("""
    <div class="annotation #{@direction}">
      <span class="target"><span class="destroy">✕</span></span>
      <div class="text-container">
        <textarea class="text" rows="1" cols="1" placeholder="Enter text…"></textarea>
      </div>
    </div>
    """)
    @$target = @$annotation.find('.target')
    @$text = @$annotation.find('.text')
    @$destroy = @$annotation.find('.destroy')
    @$annotation.appendTo(@$el)
    @$text.expanding()
  _initDraggabilly: ->
    @$text.draggabilly(axis: 'x', containment: true)
  _preventClickPropagation: ->
    @$destroy.on 'click', (e) =>
      e.stopImmediatePropagation()
      if this.isEmpty()
        this.remove()
      else
        answer = confirm 'Are you sure you want to remove this annotation?'
        return if answer is false
        this.remove()
      @annotatable.removeAnnotation(@id)
    @$annotation.on 'click', (e) => e.stopImmediatePropagation()
    @$target.on 'click', (e) =>
      e.stopImmediatePropagation()
      @$annotation.toggleClass('active')
      if @$annotation.hasClass('active')
        @$text.trigger('focus')
        @$annotation.siblings().removeClass('active')
  _switchDirection: ->
    @direction = if @direction is 'right' then 'left' else 'right'
    this._refreshStyling()
  _initStyling: ->
    @y = @clickY
    @$annotation.css(top: @y)
    if @direction is 'left'
      @x = 0
      @width = @clickX + @targetWidth
      @$annotation.css(left: @x, width: @width)
    else
      @x = @clickX
      @width = @containerWidth - @clickX
      @$annotation.css(left: @x, width: @width)
  _refreshStyling: ->
    if @direction is 'left'
      @$annotation.removeClass('right').addClass('left')
    else
      @$annotation.removeClass('left').addClass('right')

window.ajehcms = {} unless ajehcms?

class ajehcms.UploadButton
  constructor: (canvasEl, options={}) ->
    @canvas = canvasEl
    @canvasSize = options.size || [ @canvas.width, @canvas.height ].sort()[0]
    @ctx = @canvas.getContext('2d')
    @backingScale = ajeh._.backingScale(@ctx)

    @percentage = options.percentage || 0
    @strokeWidth = 2#(options.strokeWidth || 1)
    @canvasSize = options.size || @canvasSize
    @circleSize = options.size || @canvasSize
    @inactiveColor = options.inactiveColor || '#d5d5d5'
    @activeColor = options.activeColor || '#fe5948'
    @xInset = (@circleSize / 100) * 68 # 68% of circle size
    @circleCenter = @circleSize/2
    @arcRadius = @circleCenter - @strokeWidth/2

    this._initCanvas()
    this._draw()

  setProgress: (percentage) ->
    @percentage = percentage / 100.00
    this._draw()

  _initCanvas: ->
    @canvas.width = @canvasSize * @backingScale
    @canvas.height = @canvasSize * @backingScale
    @canvas.style.width = @canvasSize if @canvas.style.width isnt @canvasSize
    @canvas.style.height = @canvasSize if @canvas.style.height isnt @canvasSize
    @ctx.scale(@backingScale, @backingScale)

  _draw: ->
    # ajehcms._.requestAnimFrame => this._doDraw()
    if webkitRequestAnimationFrame
      webkitRequestAnimationFrame => this._doDraw()
    else
      requestAnimationFrame => this._doDraw()

  _doDraw: ->
    # Clear canvas
    @ctx.clearRect(0, 0, @circleSize, @circleSize)

    # Draw X
    @ctx.lineWidth = if @backingScale >= 2 then 1 else 2
    @ctx.beginPath()
    @ctx.strokeStyle = @inactiveColor
    @ctx.moveTo(@xInset, @xInset)
    @ctx.lineTo(@circleSize-@xInset, @circleSize-@xInset)
    @ctx.stroke()
    @ctx.moveTo(@xInset, @circleSize-@xInset)
    @ctx.lineTo(@circleSize-@xInset, @xInset)
    @ctx.stroke()


    @ctx.beginPath()
    @ctx.lineWidth = 1
    @ctx.lineCap = 'butt'
    @ctx.strokeStyle = @inactiveColor
    @ctx.arc(@circleCenter, @circleCenter, @arcRadius, 0, 2*Math.PI)
    @ctx.stroke()

    if @percentage < 1.0
      degrees = @percentage * 360.0
      endAngle = (degrees * Math.PI/180) + (1.5*Math.PI)
      @ctx.beginPath()
      @ctx.arc(@circleCenter, @circleCenter, @arcRadius - (@strokeWidth-2), 1.5*Math.PI, endAngle)
      @ctx.lineWidth = @strokeWidth
      @ctx.strokeStyle = @activeColor
      @ctx.lineCap = 'round'
      @ctx.stroke()

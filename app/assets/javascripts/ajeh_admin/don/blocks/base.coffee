class don.blocks.Base
  TITLE: 'Block'
  KIND: 'block'
  WRAPPER_HTML: '
  <div class="don-block don-block__<%= kind %>" id="<%= id %>">
    <div class="don-block--header">
      <span class="don-block--title"><%= title %></span>
      <span class="don-block--actions">
        <span class="don-block--moveup" data-move="up">↑ Up</span>
        <span class="don-block--movedown" data-move="down">↓ Down</span>
        <span class="don-block--remove">Remove</span>
        <span class="don-block--confirm-remove">
          Are you sure? <span data-confirm="yes">Yes</span> <span data-confirm="no">No</span>
        </span>
      </span>
    </div>
    <div class="don-block--inner"><%= yield %></div>
  </div>
  '
  HTML: ''
  constructor: (options={}) ->
    try
      @_id = _.uniqueId('don-block-')
      @editor = options.editor
      @config = options.config
      this._init()
      this._initData(options.data)
      this.init()
    catch error
      console.log error
      don.log 'Error!'
  teardown: ->
  render: ->
    don._.delay 8, => this.onRender()
    @jqRootEl
  onRender: ->
  serialize: (data) ->
    return null if _.isEmpty(data)
    # stringifiedData = JSON.stringify(data)
    # return null if stringifiedData.match(/^({}|\[\]|\"\")$/)
    output =
      kind: this.constructor::KIND
      data: data
  init: ->
    @config = don._.merge(@DEFAULT_CONFIG, @config)
  _init: ->
    this._initDom()
    @jqToolbar.on 'click', "[data-move='up']", =>
      @editor.moveBlock(this, 'up')
    @jqToolbar.on 'click', "[data-move='down']", =>
      @editor.moveBlock(this, 'down')
    # @editor
  _initData: (data) ->
    return unless data?
    @data = try
      JSON.parse(data)
    catch error
      data
  _initDom: ->
    htmlWrapper = don._.template @WRAPPER_HTML,
      kind: don._.underscored(@KIND)
      id: @_id
      title: @TITLE
      yield: @HTML
    @jqRootEl = $(htmlWrapper)
    @jqToolbar = @jqRootEl.find('.don-block--header')
    @jqEl = @jqRootEl.find('.don-block--inner')
    $jqRemove = @jqRootEl.find('.don-block--remove')
    $jqConfirmRemove = @jqRootEl.find('.don-block--confirm-remove')
    $jqConfirmRemove.on 'click', '[data-confirm="yes"]', =>
      @editor.removeBlock(this)
    $jqConfirmRemove.on 'click', '[data-confirm="no"]', ->
      $jqRemove.show()
      $jqConfirmRemove.hide()
    $jqRemove.on 'click', =>
      $jqRemove.hide()
      $jqConfirmRemove.show()
  _dataLoading: ->
    # @jqLoading.addClass('visible')
    # jqInput.hide() for jqInput in @inputs
  _dataLoaded: ->
    # @jqLoading.removeClass('visible')
  _dataNotLoaded: ->
    # @jqLoading.removeClass('visible')
    # jqInput.show().val('') for jqInput in @inputs
    # @jqLoading.transition opacity: 0, duration: 150, -> this.addClass('hidden')
  afterRender: ->
  loadData: ->

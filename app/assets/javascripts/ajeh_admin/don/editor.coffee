class don.Editor
  DEFAULTS: {}
  WRAPPER_HTML: '<div class="don-editor"></div>'
  TOOLBAR_HTML: '<div class="don-toolbar"></div>'
  TOOLBAR_BUTTON_HTML: '<a class="don-toolbar--button" data-kind="<%= kind %>"><%= title %></a>'
  HTML: '<div class="don-blocks" data-block-count="0"></div>'
  DEFAULT_CONFIG:
    singleMode: false
    defaultBlock: 'Wysiwyg'
    blocks: []
    fixedLength: null
  constructor: (el) ->
    @el = el
    @$el = $(el)
    @_id = _.uniqueId('don-editor-')
    don.log 'Initalizing don', this
    this._init()
    don._instances.push this
    this
  serialize: ->
    data = []
    for block in @blocks
      serializedBlock = block.serialize()
      data.push serializedBlock if serializedBlock and (serializedBlock isnt '' or serializedBlock isnt {})
    data
  serializeAsJson: ->
    JSON.stringify this.serialize()
  _init: ->
    this._parseConfig()
    this._fetchDomElements()
    this._initDom()
    this._initBlocks()
    this._bindEvents()
  _parseConfig: ->
    @config = @$el.data('don-config')
    @config = don._.merge(@DEFAULT_CONFIG, @config)
    unless @config.blocks.length
      for blockKind of don.blocks
        @config.blocks.push blockKind
    don.log 'Instance config', @config
  _fetchDomElements: ->
    @jqEl = $(@el)
    @jqForm = @jqEl.parents('form')
  _initDom: ->
    @jqEl.wrap(@WRAPPER_HTML)
    # @jqEl.hide()
    @jqWrapper = @jqEl.parents('.don-editor')
    @jqWrapper.addClass('__single_mode') if @config.singleMode
    @jqWrapper.append(@HTML)
    @jqBlocksContainer = @jqWrapper.find('.don-blocks')
    this._initBlocksToolbarDom() unless @config.fixedLength?
  _initBlocksToolbarDom: ->
    @jqBlocksToolbar = $(don._.template(@TOOLBAR_HTML))
    for blockKind of don.blocks
      continue if blockKind is 'Base'
      continue if @config.blocks? and blockKind not in @config.blocks
      don.log "Block enabled: #{blockKind}"
      title = don.blocks[blockKind]::TITLE
      buttonHtml = don._.template(@TOOLBAR_BUTTON_HTML, kind: blockKind, title: title)
      @jqBlocksToolbar.append(buttonHtml)
    @jqBlocksToolbar.find('.toggle').on 'mouseenter', -> $(this).parent().addClass('open')
    @jqBlocksToolbar.on 'mouseleave', -> $(this).removeClass('open')
    @jqBlocksToolbar.find('a').on 'click', (e) =>
      jqLink = $(e.currentTarget)
      kind = jqLink.data('kind')
      block = jqLink.parents('.don-block')
      this._addBlock(kind)
    @jqBlocksToolbar.appendTo(@jqWrapper)
  _initBlocks: ->
    @blocksInitialized = false
    @blocks = []
    # Load data from original element
    elVal = @jqEl.val()
    if elVal? and !elVal.match(/^\s*?$/) and elVal != '[]' and elVal != 'null'
      blocksData = JSON.parse(elVal)
      don.log 'Loading blocks data from JSON', blocksData
      for blockData in blocksData
        continue if _.isEmpty(blockData)
        kind = blockData.kind
        data = blockData.data
        this._addBlock(kind, data: data)
    else
      don.warn "No blocks data to load. Creating the default block: #{@config.defaultBlock}"
      if @config.fixedLength?
        this._addBlock(@config.defaultBlock) for [1..@config.fixedLength]
      else
        this._addBlock(@config.defaultBlock)
    @blocksInitialized = true
  _addBlock: (blockKind, options={}) ->
    try
      if blockKind not in @config.blocks
        don.warn "Block not available: #{blockKind}. Using the default block: #{@config.defaultBlock}"
        blockKind = @config.defaultBlock
      unless don.blocks[blockKind]?
        don.error "Failed to create a block of kind: #{blockKind}"
        return
      don.log "Creating a block of kind: #{blockKind}"
      options =
        editor: this
        data: options.data
      if @config.blocksConfig? and @config.blocksConfig[blockKind]?
        options.config = @config.blocksConfig[blockKind]
      block = new don.blocks[blockKind] options
      block.setPosition(@blocks.length)
      jqBlock = block.render()
      animate = options.after? || options.before?
      insertLocation = if options.after then 'after' else if options.before then 'before' else 'after'
      targetBlockEl = options[insertLocation] if options[insertLocation]
    catch error
      don.error 'Error adding block', error

    # jqBlock.css(transformOrigin: 'top left', scale: 0) if animate
    if insertLocation is 'after'
      if targetBlockEl
        $(targetBlockEl).after(jqBlock)
      else
        @jqBlocksContainer.append(jqBlock)
    else if insertLocation is 'before'
      if targetBlockEl
        jqTarget.before(jqBlock)
      else
        @jqBlocksContainer.prepend(jqBlock)
    # jqBlock.transition(scale: 1, duration: 150) if animate
    # jqToolbar = @jqBlocksToolbar.clone(true)
    # jqToolbar.appendTo(jqBlock)
    @blocks.push block
    @jqBlocksContainer.attr('data-block-count', @blocks.length)
    block.afterRender() if @blocksInitialized
  removeBlock: (blockToRemove) ->
    @blocks = _.without(@blocks, blockToRemove)
    blockToRemove.jqRootEl.remove()
    @jqBlocksContainer.attr('data-block-count', @blocks.length)
    this._setBlockPositions()
  moveBlock: (block, direction) ->
    jqCurrent = block.jqRootEl
    animationTiming = 200
    if direction is 'up'
      jqPrevious = jqCurrent.prev()
      return if jqPrevious.length is 0
      offset = jqPrevious.offset().top - jqCurrent.offset().top
      jqCurrent.velocity translateY: [offset,0], animationTiming
      jqPrevious.velocity translateY: [jqCurrent.outerHeight(),0], animationTiming, ->
        jqCurrent.insertBefore(jqPrevious)
        jqCurrent.removeAttr('style')
        jqPrevious.removeAttr('style')
    else if direction is 'down'
      jqNext = jqCurrent.next()
      return if jqNext.length is 0
      offset = jqNext.offset().top - jqCurrent.offset().top
      jqCurrent.velocity translateY: [jqNext.outerHeight(), 0], animationTiming
      jqNext.velocity translateY: [offset * -1, 0], animationTiming, ->
        jqCurrent.insertAfter(jqNext)
        jqCurrent.removeAttr('style')
        jqNext.removeAttr('style')
    don._.move(block, @blocks, direction)
    this._setBlockPositions()
  _setBlockPositions: ->
    block.setPosition(i) for block, i in @blocks
  _updateInput: ->
    @jqEl.val this.serializeAsJson()
  _bindEvents: ->
    return if @jqForm.data('don')?
    @jqForm.data('don', true)
    @jqForm.on 'submit.don', (e) =>
      e.preventDefault()
      instance._updateInput() for instance in don._instances
      @jqForm.off('.don').trigger('submit')

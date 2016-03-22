class don.blocks.Gallery extends don.blocks.Base
  TITLE: 'Photo Gallery'
  KIND: 'gallery'
  HTML: '''
    <div class="don-block__gallery--items"></div>
  '''
  DEFAULT_CONFIG:
    captions: true
  init: ->
    inputHtml = '<input class="don-block__gallery--fileinput" type="file" name="file" multiple="true">'
    @jqItems = @jqEl.find('.don-block__gallery--items')
    @config = don._.merge(@DEFAULT_CONFIG, @config)
    appendItem = (url, options={}) =>
      id = if options.id then options.id else null
      public_id = if options.public_id then options.public_id else null
      cloudinary = if options.cloudinary then options.cloudinary else null
      caption = if options.caption then options.caption else ''
      $item = $ if @config.captions
        """
          <div class="don-block__gallery-item" data-id="#{id}" data-public-id="#{public_id}">
            <div class="don-block__gallery-item--preview">
              <img class="don-block__gallery-item--img" src="#{url}">
              <div class="don-block__gallery-item--actions">
                <span class="don-block__gallery-item--action" data-move="up">↑</span>
                <span class="don-block__gallery-item--action" data-action="remove">╳</span>
                <span class="don-block__gallery-item--action" data-move="down">↓</span>
              </div>
            </div>
            <input class="don-block__gallery-item--captioninput" type="text" placeholder="Caption" value="#{caption}">
          </div>
        """
      else
        """
          <div class="don-block__gallery-item" data-id="#{id}" data-public-id="#{public_id}">
            <div class="don-block__gallery-item--preview">
              <img class="don-block__gallery-item--img" src="#{url}">
              <div class="don-block__gallery-item--actions">
                <span class="don-block__gallery-item--action" data-move="up">↑</span>
                <span class="don-block__gallery-item--action" data-action="remove">╳</span>
                <span class="don-block__gallery-item--action" data-move="down">↓</span>
              </div>
            </div>
          </div>
        """
      @jqItems.append($item)
      $item.data('cloudinary', JSON.parse(cloudinary))
      $item

    if @data
      for item in @data
        url = if item.public_id?
          "/uploads/store/#{item.public_id}"
        else
          'http://placehold.it/500?text=Image+Failed+To+Upload'
        if @config.captions
          appendItem(url, caption: item.caption, public_id: item.public_id, cloudinary: JSON.stringify(item.cloudinary))
        else
          appendItem(url, public_id: item.public_id, cloudinary: JSON.stringify(item.cloudinary))
    else
      @data = []

    animationTiming = 200

    @jqEl.on 'click', '[data-action]', ->
      if $(this).data('action') is 'remove'
        return unless confirm 'Are you sure you want to remove this photo?'
        jqItem = $(this).parents('.don-block__gallery-item')
        jqItem.remove()

    @jqEl.on 'click', '[data-move]', ->
      $this = $(this)
      direction = $this.data('move')
      if direction is 'down'
        jqCurrent = $(this).parents('.don-block__gallery-item')
        jqNext = jqCurrent.next('.don-block__gallery-item')
        return if jqNext.length is 0
        offset = jqNext.offset().top - jqCurrent.offset().top
        jqCurrent.velocity translateY: [jqNext.outerHeight(), 0], animationTiming
        jqNext.velocity translateY: [offset * -1, 0], animationTiming, ->
          jqCurrent.insertAfter(jqNext)
          jqCurrent.removeAttr('style')
          jqNext.removeAttr('style')
      else if direction is 'up'
        jqCurrent = $(this).parents('.don-block__gallery-item')
        jqPrevious = jqCurrent.prev('.don-block__gallery-item')
        return if jqPrevious.length is 0
        offset = jqPrevious.offset().top - jqCurrent.offset().top
        jqCurrent.velocity translateY: [offset,0], animationTiming
        jqPrevious.velocity translateY: [jqCurrent.outerHeight(),0], animationTiming, ->
          jqCurrent.insertBefore(jqPrevious)
          jqCurrent.removeAttr('style')
          jqPrevious.removeAttr('style')

    @onInputChange = (e) =>
      for file in e.currentTarget.files
        url = don._.imageURL(file)
        id = don._.stringHash(file.name)
        jqFile = appendItem(url, id: id)
        that = this
        new don.FileUpload file,
          done: (response) ->
            id = don._.stringHash(@file.name)
            jqItem = that.jqItems.find("[data-id='#{id}']")
            console.log jqItem
            jqItem.data('public-id', response.id)
            jqItem.data('cloudinary', response.meta)

    @jqFileInput = $(inputHtml)
    @jqFileInput.appendTo(@jqEl)
    @jqFileInput.on('change', @onInputChange)
  serialize: ->
    @data = []
    @jqItems.children().each (i, el) =>
      $el = $(el)
      if @config.captions
        @data.push {
          public_id: $el.data('public-id'),
          cloudinary: $el.data('cloudinary'),
          caption: $el.find('.don-block__gallery-item--captioninput').val()
        }
      else
        @data.push {
          public_id: $el.data('public-id'),
          cloudinary: $el.data('cloudinary')
        }
    super @data
  afterRender: ->

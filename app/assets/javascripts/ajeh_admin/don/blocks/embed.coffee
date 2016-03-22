class don.blocks.Embed extends don.blocks.Base
  TITLE: 'Video Embed'
  KIND: 'embed'
  HTML: '''
    <div class="don-block__embed--preview"><canvas></canvas></div>
    <input class="don-block__embed--captioninput" type="text" placeholder="Caption">
    <div class="don-block__embed--input">
      <input class="empty" type="text" placeholder="Video URL (YouTube, Vimeo etc.)">
      <button type="button">Add</button>
    </div>
  '''
  init: ->
    @jqCaptionInput = @jqEl.find('.don-block__embed--captioninput')
    @jqCaptionInput.hide()
    @jqInput = @jqEl.find('.don-block__embed--input input')
    @jqInput.on 'keyup paste', =>
      if @jqInput.val() is ''
        @jqInput.addClass('empty')
      else
        @jqInput.removeClass('empty')
    @jqButton = @jqEl.find('button')
    @jqPreview = @jqEl.find('.don-block__embed--preview')
    renderPreview = =>
      # NOTE: Handle bad data (kind of)
      return unless @data.kind?
      return unless @data.kind is 'video' or @data.kind is 'rich'
      @jqEl.find('.don-block__embed--input').hide()
      @jqCaptionInput.show().val(@data.caption)
      @jqPreview.append(@data.html)
      @jqPreview.find('canvas')
        .attr('width', @data.width)
        .attr('height', @data.height)
    renderPreview() if @data?
    handlePaste = => don._.delay 1, =>
      @data = {}
      this._dataLoading()
      url = @jqInput.val()
      apiKey = '1addbb81bab1432c909cb35c93c02cbe'
      url = encodeURIComponent(url)
      apiUrl = "//api.embed.ly/1/oembed?key=#{apiKey}&url=#{url}"
      parseEmbedlyResponse = (response) =>
        console.log response
        @data.url = url
        @data.kind = response.type
        embedHtml = switch response.type
          when 'photo'
            @data.image_url = response.url
            "<img src=\"#{response.url}\">"
          when 'video', 'rich'
            html = response.html
            @data.width = response.width
            @data.height = response.height
            @data.provider = response.provider_name.toLowerCase()
            html = "<div class=\"iframe-container #{@data.provider}\">#{html}</div>" if html.match(/iframe/)
            @data.html = html
            html
          when 'link'
            @data.url = response.url
            @data.thumbnail_url = response.thumbnail_url
            @data.title = response.title
            @data.description = response.description
        renderPreview(@data)
        this._dataLoaded()
      $.ajax
        # dataType: 'jsonp'
        url: apiUrl
        success: parseEmbedlyResponse
        error: =>
          don.log 'embedly error'
          @jqInput.val('').show()
          this._dataNotLoaded()
    @jqButton.on 'click', handlePaste
  serialize: ->
    if @jqCaptionInput.val() isnt ''
      @data.caption = @jqCaptionInput.val()
    super @data
  afterRender: ->
    @jqInput.focus()

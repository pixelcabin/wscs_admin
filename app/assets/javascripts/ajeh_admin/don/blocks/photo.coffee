class don.blocks.Photo extends don.blocks.Base
  TITLE: 'Single Photo'
  KIND: 'Photo'
  HTML: '''
    <div class="don-block__photo--preview"></div>
    <input class="don-block__photo--captioninput" type="text" placeholder="Caption">
    <label class="don-block__photo--fullwidthlabel"><input class="don-block__photo--fullwidthinput" type="checkbox"> Full width?</label>
    <input class="don-block__photo--fileinput" type="file" name="file">
  '''
  init: ->
    @jqImagePreview = @jqEl.find('.don-block__photo--preview')
    @jqFullWidthLabel = @jqEl.find('.don-block__photo--fullwidthlabel')
    @jqFullWidthInput = @jqEl.find('.don-block__photo--fullwidthinput')
    @jqCaptionInput = @jqEl.find('.don-block__photo--captioninput')
    @jqFileInput = @jqEl.find('.don-block__photo--fileinput')

    if @data?
      url = "/uploads/store/#{@data.id}"
      @jqImagePreview.append("<img src=\"#{url}\">")
      @jqFileInput.remove()
      @jqCaptionInput.val(@data.caption).show()
      @jqFullWidthInput.prop('checked', @data.fullWidth)
    else
      @data = {}
      @jqFullWidthLabel.hide()
      @jqCaptionInput.hide()
    @jqFileInput.on 'change', (e) =>
      file = e.currentTarget.files[0]
      url = don._.imageURL(file)
      @jqImagePreview.append("<img src=\"#{url}\">")
      @jqFullWidthLabel.show()
      @jqCaptionInput.show()
      @jqFileInput.hide()
      console.log @jqFileInput
      that = this
      new don.FileUpload file,
        done: (response) =>
          @data.id = response.id

  serialize: ->
    @data.caption = @jqCaptionInput.val()
    @data.fullWidth = @jqFullWidthInput.is(':checked')
    super @data
  afterRender: ->
    # @jqInput.click()

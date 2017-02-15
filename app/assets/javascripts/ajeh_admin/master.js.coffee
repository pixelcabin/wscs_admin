window.ajaxBusy = false

$(document).on 'keyup', (e) ->
  return unless e.ctrlKey and e.keyCode == 70
  e.preventDefault()
  $('body').toggleClass('fullpage')

ready = ->
  FastClick.attach(document.body)

  if window.devicePixelRatio and devicePixelRatio >= 2
    testElem = document.createElement('div')
    testElem.style.border = '.5px solid transparent'
    document.body.appendChild(testElem)
    if testElem.offsetHeight is 1
      document.querySelector('html').classList.add('support-css-hairlines');
    document.body.removeChild(testElem)

  # window.googleMapsLoaded = ->
  #   window.googleMapsDidLoad = true
  #   $(document).trigger('google-maps-loaded')

  # window.onGoogleMapsLoad = (fn) ->
  #   if window.googleMapsDidLoad
  #     fn.call()
  #   else
  #     $(document).on('google-maps-loaded', fn)

  # unless window.googleMapsDidLoad
  #   $script = $ '<script>',
  #     type: 'text/javascript'
  #     src: 'https://maps.googleapis.com/maps/api/js?libraries=places&key=AIzaSyAZOysega_DA0M9e-vElE11GsW8o65AF3g&v=3.exp&signed_in=true&callback=googleMapsLoaded'
  #   $script.appendTo('body')

  pageScripts.load()

  $(document).on 'cocoon:after-insert', (e, added) ->
    $(added).find('textarea').expanding()


  $(document).on 'mouseover', 'a.remove_fields', ->
    $(this).parents('.nested-fields').addClass('remove')

  $(document).on 'mouseout', 'a.remove_fields', ->
    $(this).parents('.nested-fields').removeClass('remove')

  $('textarea[data-wysiwyg]').each ->
    $textarea = $(this)
    wysiwygConfig = $textarea.data('wysiwyg-config')
    $textarea.redactor(wysiwygConfig)

  $('table[data-sortable]').each ->
    $table = $(this)
    url = $table.data('sortable')
    $table.find('tbody').sortable
      axis: 'y'
      items: 'tr'
      handle: '.handle'
      helper: (e, tr) ->
        $originals = tr.children()
        $helper = tr.clone()
        $helper.children().each (index) -> $(this).width($originals.eq(index).outerWidth())
        $helper
      forcePlaceholderSize: true
      update: ->
        array = {}
        for tr, i in $table.find('tr')
          id = $(tr).data('id')
          array[id] = i+1
        $.ajax
          url: url
          type: 'POST'
          data:
            _method: 'PATCH'
            records: array

  # layoutPageHeader = ->
  #   widths = []
  #   $('#page-header a').each (el, i) -> widths.push $(this).outerWidth()
  #   largestWidth = widths.sort()[widths.length-1]
  #   # $('#page-header').css(padding: "0 #{largestWidth}px")
  #   $('#page-header').css(paddingRight: "0 #{largestWidth}px")
  # $(window).on 'resize', layoutPageHeader
  # layoutPageHeader()

  jqPageOverlay = $('<div id="page-overlay">')
  jqPageOverlay.appendTo('#page')

  # if $('#page-header a:contains(Cancel)').length
  #   $('#header').hide()
  #   $('#page-header').addClass('full-width')

  # if Modernizr.touch
  #   jqPageOverlay.on 'touchstart', (e) ->
  #     e.preventDefault()
  #     e.stopPropagation()
  #   $('#header').on 'click', ->
  #     $('body').toggleClass('nav-open')
  #   jqPageOverlay.on 'touchend', ->
  #     $('body').removeClass('nav-open')
  # else
  #   headerTimeout = null
  #   $('#header').on
  #     mouseenter: ->
  #       clearTimeout(headerTimeout)
  #       $('body').addClass('nav-open')
  #     mouseleave: ->
  #       headerTimeout = ajeh._.delay 300, -> $('body').removeClass('nav-open')

  $('[data-action]').addClass('clickable').on 'click', (e) ->
    destination = $(this).data('action')
    if Turbolinks?
      Turbolinks.visit(destination)
    else
      window.location = destination

  $('input[type="text"], textarea').each ->
    $this = $(this)
    return if $this.attr('placeholder')?
    id = $this.attr('id')
    $label = $("label[for='#{id}']")
    if $label.length and $label.text() isnt ''
      $this.attr('placeholder', $label.text())
    else
      $this.attr('placeholder', '…')

  # $('input, textarea').attr('placeholder', '…')

  $('.field').on
    focusin: -> $(this).addClass('focussed')
    focusout: -> $(this).removeClass('focussed')

  # $('.field > label').each -> $(this).text("#{$(this).text()}:")

  $('#page-footer a.form-submit').on 'click', (e) ->
    e.preventDefault()
    return if ajaxBusy
    $('form:not(.button_to)').submit()

  $('.flash').velocity
    p:
      translateY: [ '0%', '-100%' ]
    o:
      duration: 500
      delay: 300,
      easing: [ 500, 20 ]
  removeFlash = (flash) ->
    $(flash).velocity
      p:
        translateY: [ '-100%', '0%' ]
      o:
        duration: 500
        easing: [ 500, 20 ]
        complete: ->
          $(this).remove() if this?
  $('.flash').on 'click', -> removeFlash(this)
  ajeh._.delay 5000, -> removeFlash('.flash')

  # Form label widths
  # ajeh._.delay 50, ->
  #   $('form').each ->
  #     $form = $(this)
  #     widths = $form.find('.field > label').map(-> $(this).width()
  #     ).get().sort((a, b) ->
  #       b - a
  #     )
  #     # $form.css maxWidth: 700
  #     # $form.css(maxWidth: 700 + widths[0] + 20)
  #     # $form.css maxWidth: 700 + (widths[0])*2 + 30
  #     # $form.css paddingRight: "+=#{widths[0]}"
  #     $form.find('.field > label').css width: widths[0]
  #     $form.find('legend span').css marginLeft: widths[0] + 20
  #     # $form.find('.actions').css marginLeft: widths[0] + 20
  #     # $('.destroy_form').find('div').css maxWidth: 700 + (widths[0])*2
  #     # $('.destroy_form').find('div').css maxWidth: 700

  # # jqHeader = $('#header')
  # # jqHeader.data('open', true).on 'click', ->
  # #   if jqHeader.data('open')
  # #     jqHeader.transition(width: 80)
  # #     jqHeader.find('nav').transition(x: '-100%')
  # #     $('#page').transition left: 80, -> jqHeader.data('open', false)
  # #   else
  # #     jqHeader.transition(width: 280)
  # #     jqHeader.find('nav').transition(x: 0)
  # #     $('#page').transition left: 280, -> jqHeader.data('open', true)

  $(':input[size]').autoGrowInput()

  $('.rome-datetime').each ->
    romeInput = document.createElement('div')
    $field = $(this)
    $field.find('.controls').prepend(romeInput)
    $input = $field.find(':input:first')
    romeInstance = rome romeInput,
      initialValue: $input.val()
      timeInterval: 60 * 15
      timeFormat: 'h:mma'
      weekStart: 1
    $input.data('rome', romeInstance)
    rome(romeInput).on 'data', (value) ->
      $input.val(value)
    $input.val rome(romeInput).getDateString()

  $('.rome-date').each ->
    romeInput = document.createElement('div')
    $field = $(this)
    $field.find('.controls').prepend(romeInput)
    $input = $field.find(':input:first')
    inputRomeOptions = $input.data('rome') || {}
    romeOptions = $.extend inputRomeOptions,
      initialValue: $input.val()
      time: false
      weekStart: 1
    rome(romeInput, romeOptions)
    rome(romeInput).on 'data', (value) ->
      $input.val(value)
    $input.val rome(romeInput).getDateString()

  $('.date input').pickadate
    firstDay: 1
    weekdaysShort: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
    format: 'dddd, d mmmm yyyy'
    formatSubmit: 'yyyy-mm-dd'

  $('.time input').pickatime()

  $('input[type="radio"]:checked').parent().addClass('checked')
  $('input[type="radio"]').on 'click', ->
    jqRadioButton = $(this)
    jqRadioButton.parent().addClass('checked').siblings().removeClass('checked')

  # File uploads
  $(':file.ajeh-uploader-simple').each ->
    jqInput = $(this)
    jqFilePreview = jqInput.parent().find('.file-preview')
    jqInput.on 'change', (e) ->
      # Destroy existing file preview
      jqFilePreview.empty()
      # Create file preview
      jqPreview = $('<img>', width: 220).hide().appendTo(jqFilePreview)
      jqHiddenInput = $('<input>', type: 'hidden', name: jqInput.attr('name'))
      jqHiddenInput.insertAfter(jqInput)
      # Create the file upload
      file = this.files[0]
      fileUpload = new FileUpload file,
        done: (key) ->
          url = ajeh.FileUploads.url_for("#{key}.jpg")
          jqHiddenInput.val(key)
      jqPreview.attr('src', fileUpload.previewSrc()).show()
  $('.ajeh-image-crop-upload').each ->
    jqThis = $(this)
    modelName = jqThis.parents('form').data('model')
    jqInput = jqThis.find(':file')
    jqFilePreview = jqThis.find('.file-preview')
    jqFilePreviewImage = jqFilePreview.find('img')
    jqCropInput = $("##{modelName}_cover_crop")
    savedCrop = jqFilePreviewImage.data('crop')
    if jqFilePreviewImage.length
      jCropApi = null
      jCropOptions =
        boxWidth: 640
        setSelect: [savedCrop.x, savedCrop.y, savedCrop.x2, savedCrop.y2]
        aspectRatio: 2
        onSelect: (c) -> jqCropInput.val JSON.stringify(c)
      jqFilePreviewImage.Jcrop jCropOptions, -> jCropApi = this
    jqInput.on 'change', (e) ->
      # Destroy existing jCrop instance
      jCropApi.destroy() if jCropApi
      # Create file preview
      jqInput.nextAll('input').remove()
      jqHiddenInput = $('<input>', type: 'text', name: jqInput.attr('name'))
      jqHiddenInput.insertAfter(jqInput)
      jqFilePreview.empty()
      jqFilePreviewImage = $('<img>')
      jqFilePreviewImage.appendTo(jqFilePreview)
      # Create the file upload
      file = this.files[0]
      fileUpload = new FileUpload file, done: (key) ->
        url = ajeh.FileUploads.url_for("#{key}.jpg")
        jqHiddenInput.val(key)
      jqFilePreviewImage.attr('src', fileUpload.previewSrc()).Jcrop
        boxWidth: 640
        setSelect: [0,0,10000,10000]
        aspectRatio: 2
        onSelect: (c) -> jqCropInput.val JSON.stringify(c)

  # window.editor = new Don.Editor(selector: '.don')

  $('[data-don]').each ->
    new don.Editor(this)

  $(document).ajaxStart ->
    ajaxBusy = true
    $('a.form-submit').addClass('disabled')
    # $('#busy-indicator').addClass('visible')
  $(document).ajaxComplete ->
    ajaxBusy = false
    $('a.form-submit').removeClass('disabled')
    # $('#busy-indicator').removeClass('visible')

  # Auto-expanding textareas
  # $('textarea:not(.wysiwyg)').expanding().on 'keydown', (e) ->
  #   e.preventDefault() if e.originalEvent.keyCode is 13
  $('.controls-text-area textarea').expanding()

  # Toggle form fields
  $('[data-toggle-name]').each ->
    jqField = $(this)
    fieldName = jqField.data('toggle-name')
    fieldVal = jqField.data('toggle-val')
    jqToggleField = $("[name='#{fieldName}'")
    jqToggleField.on 'change', ->
      if $(this).val() is fieldVal then jqField.show() else jqField.hide()
    if jqToggleField.filter(':checked').val() is fieldVal then jqField.show() else jqField.hide()

if window.Turbolinks?
  $(document).on 'turbolinks:load', ready
else
  $ -> ready()

# $(document).on 'page:load', ->
#   ajeh._.delay 1, -> $('#page').scrollTop(0)

# $(document).on 'page:before-change', -> $('#busy-indicator').css(opacity: 1, width: '30%')
# $(document).on 'page:fetch', -> $('#busy-indicator').css(width: '60%')
# $(document).on 'page:receive', -> $('#busy-indicator').css(width: '90%')
# $(document).on 'page:load', -> $('#busy-indicator').css(width: '100%')

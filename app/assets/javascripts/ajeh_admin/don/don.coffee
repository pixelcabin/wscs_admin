window.don ?= {}

don.DEBUG = true
don.VERSION = '0.0.1'
don.URL_REGEX = /^(?:([A-Za-z]+):)?(\/{0,3})([0-9.\-A-Za-z]+)(?::(\d+))?(?:\/([^?#]*))?(?:\?([^#]*))?(?:#(.*))?$/
don.URL_API = if URL? then URL else if webkitURL? then webkitURL else null
don._instances = []
don.blocks = {}

class don.FileUpload
  constructor: (file, options={}) ->
    @file = file
    data = new FormData()
    data.append 'file', @file

    ajaxRequest = $.ajax
      type: 'POST'
      url: '/admin/uploads'
      data: data
      cache: false
      contentType: false
      processData: false
    ajaxRequest.done (response) => options.done.call(this, response) if options.done?
    ajaxRequest.fail (response) => options.fail.call(this, response) if options.fail?
    ajaxRequest.always (response) => options.always.call(this, response) if options.always?

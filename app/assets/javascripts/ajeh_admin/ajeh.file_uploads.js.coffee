window.ajeh = {} unless ajeh?

ajeh.FileUploads =
  _transformationStringMappings:
    width: 'w'
    height: 'h'
    resize: 'r'
    quality: 'q'
  url_for: (key, transformationOptions) ->
    transformationString = []
    for k, v of transformationOptions
      mappedKey = this._transformationStringMappings[k]
      continue unless mappedKey
      transformationString.push [ mappedKey, v ].join('_')
    transformationString = transformationString.join(',')
    "/file-uploads/#{transformationString}/#{key}"

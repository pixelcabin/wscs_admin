class don.blocks.Wysiwyg extends don.blocks.Base
  TITLE: 'Text'
  KIND: 'Wysiwyg'
  HTML: '<textarea placeholder="Text"></textarea>'
  init: ->
    @jqTextarea = @jqEl.find('textarea')
    @jqTextarea.redactor
      toolbar: true
      buttons: [
        'html'
        'bold'
        'italic'
        'link'
        'unorderedlist'
        'orderedlist'
      ]
      linkTooltip: true
  loadData: ->
    return unless @data?
    @jqTextarea.redactor('code.set', @data)
  serialize: ->
    super @jqTextarea.redactor('code.get')

class don.blocks.Wysiwyg extends don.blocks.Base
  TITLE: 'Text'
  KIND: 'wysiwyg'
  HTML: '<textarea placeholder="Text"></textarea>'
  init: ->
    @jqTextarea = @jqEl.find('textarea')
    @jqTextarea.val(@data) if @data?
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
  afterRender: ->
    @jqTextarea.redactor('core.getEditor').focus()
  serialize: ->
    super @jqTextarea.redactor('code.get')

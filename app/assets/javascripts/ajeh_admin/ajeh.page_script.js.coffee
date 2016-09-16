window.ajeh = {} unless window.ajeh?

unless ajeh.Singleton?
  class ajeh.Singleton
    @sharedInstance: -> @_instance ?= new @(arguments...)

class ajeh.PageScript extends ajeh.Singleton
  constructor: ->
    @pagescripts = {}
  load: ->
    identifier = if document.body.dataset
      document.body.dataset['ajehPagescript']
    else
      document.body.getAttribute('data-ajeh-pagescript')
    @pagescripts[identifier].call() if @pagescripts[identifier]?
  register: (identifier, callback) ->
    @pagescripts[identifier] = callback

window.pageScripts = ajeh.PageScript.sharedInstance()

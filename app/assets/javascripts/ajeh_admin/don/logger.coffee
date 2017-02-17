don.log = (message...) ->
  message.unshift('log')
  don._logger.apply this, message
don.warn = (message...) ->
  message.unshift('warn')
  don._logger.apply this, message
don.error = (message...) ->
  message.unshift('error')
  don._logger.apply this, message
don._logger = (level, message...) ->
  return unless console? && don.DEBUG
  now = new Date
  hour = now.getHours()
  minutes = now.getMinutes()
  minutes = "0#{minutes}" if minutes < 10
  seconds = now.getSeconds()
  seconds = "0#{seconds}" if seconds < 10
  timestamp = "#{hour}:#{minutes}:#{seconds}"
  if message.length is 1 and typeof message[0] is 'string'
    console[level]("%cdon #{timestamp}%c#{message[0]}", 'display:inline-block;padding:2px 3px;margin-right:5px;background-color:#F34F4E;color:white;', 'color:black;')
  else
    mainMessage = message.shift()
    console[level]("%cdon #{timestamp}%c▼ #{mainMessage}", 'display:inline-block;padding:2px 3px;margin-right:5px;background-color:#F34F4E;color:white;', 'color:black;')
    console[level](m) for m in message

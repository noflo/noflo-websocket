noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'connection',
    datatype: 'object'
  c.outPorts.add 'string',
    datatype: 'string'
  c.outPorts.add 'binary',
    datatype: 'buffer'
  c.forwardBrackets = {}
  c.autoOrdering = false
  c.process (input, output) ->
    return unless input.hasData 'connection'
    connection = input.getData 'connection'
    if noflo.isBrowser()
      connection.addEventListener 'message', (message) ->
        output.send
          string: message.data
      , false
      connection.addEventListener 'close', (message) ->
        output.done()
      , false
      return
    connection.on 'message', (message) ->
      if message.type is 'utf8'
        output.send
          string: message.utf8Data
        return
      if message.type is 'binary'
        output.send
          binary: message.binaryData
        return
    connection.on 'close', ->
      output.done()

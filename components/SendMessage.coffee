noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add  'connection',
    datatype: 'object'
  c.inPorts.add 'string',
    datatype: 'string'
  c.connections = {}
  c.tearDown = (callback) ->
    c.connections = {}
    do callback
  c.process (input, output) ->
    if input.hasData 'connection'
      c.connections[input.scope] = input.getData 'connection'
      output.done()
      return
    return unless c.connections[input.scope]
    return unless input.hasData 'string'
    message = input.getData 'string'
    if noflo.isBrowser()
      c.connections[input.scope].send message
      output.done()
      return
    c.connections[input.scope].sendUTF message
    output.done()
    return

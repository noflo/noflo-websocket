noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add  'connection',
    datatype: 'object'
    control: true
  c.inPorts.add 'string',
    datatype: 'string'

  c.process (input, output) ->
    return unless input.hasData 'connection', 'string'

    [connection, message] = input.getData 'connection', 'string'
    if noflo.isBrowser()
      connection.send message
    else
      connection.sendUTF message
    output.done()

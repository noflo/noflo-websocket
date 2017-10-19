noflo = require 'noflo'
WsClient = WebSocket

# @runtime noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'url',
    datatype: 'string'
  c.inPorts.add 'protocol',
    datatype: 'string'
    default: ''
    control: true
  c.outPorts.add 'connection',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'url'
    return if input.attached('protocol').length and not input.hasData 'protocol'
    protocol = ''
    if input.hasData 'protocol'
      protocol = input.getData 'protocol'

    url = input.getData 'url'
    client = new WsClient url, protocol
    client.onerror = (err) ->
      output.done err
    client.onopen = ->
      output.sendDone
        connection: client
    return

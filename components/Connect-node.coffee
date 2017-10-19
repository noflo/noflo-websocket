noflo = require 'noflo'
WsClient = require('websocket').client

# @runtime noflo-nodejs
# @name Connect

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
    client = new WsClient
    client.on 'connectFailed', (err) ->
      output.done err
    client.on 'connect', (connection) ->
      output.sendDone
        connection: connection
    client.connect url, protocol
    return

noflo = require 'noflo'
WsClient = require('websocket').client
URL = require('url')
Buffer = require('buffer').Buffer

# @runtime noflo-nodejs
# @name Connect

btoa = (str) ->
    return new Buffer(str).toString('base64');

basicAuth = (user, password) ->
  token = user + ":" + password
  return "Basic " + btoa(token)

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

    # Support HTTP Basic Auth
    headers = {}
    u = URL.parse url
    if u.auth
      [user, pass] = u.auth.split ':'
      headers['Authorization'] = basicAuth(user, pass)

    client.connect url, protocol, null, headers

    return

noflo = require 'noflo'
{server} = require 'websocket'

# @runtime noflo-nodejs

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Listen for WebSocket upgrade requests on a HTTP server'
  c.inPorts.add 'server',
    datatype: 'object'
  c.inPorts.add 'protocol',
    datatype: 'string'
    default: ''
    control: true
  c.outPorts.add 'connection',
    datatype: 'object'
  c.outPorts.add 'url',
    datatype: 'object'
  c.outPorts.add 'ip',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
  c.servers = []
  c.forwardBrackets = {}
  c.autoOrdering = false
  c.tearDown = (callback) ->
    for server in c.servers
      for connection in server.connections
        # REASON_GOING_AWAY
        connection.drop 1001
      server.ws.shutDown()
      server.ctx.deactivate()
    c.servers = []
    do callback
  c.process (input, output, context) ->
    return unless input.hasData 'server'
    return if input.attached('protocol').length and not input.hasData 'protocol'
    protocol = ''
    if input.hasData 'protocol'
      protocol = input.getData 'protocol'
    serverData =
      http: input.getData 'server'
      ctx: context
      connections: []
    serverData.ws = new server
      httpServer: serverData.http
    c.servers.push serverData
    serverData.ws.on 'request', (request) ->
      try
        connection = request.accept protocol, request.origin
      catch err
        prots = request.requestedProtocols.join ', '
        err = new Error "Accepting #{@protocol} failed, requested #{prots}"
        # Note: using normal send instead of error method since we want to
        # keep the context alive
        output.send
          error: err
        return
      output.send
        connection: new noflo.IP 'data', connection,
          scope: request.key
        url: new noflo.IP 'data', request.resourceURL,
          scope: request.key
        ip: new noflo.IP 'data', request.remoteAddress,
          scope: request.key

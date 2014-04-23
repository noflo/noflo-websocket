noflo = require 'noflo'
{server} = require 'websocket'

# @runtime noflo-nodejs

class ListenConnections extends noflo.Component
  description: 'Listen for WebSocket upgrade requests on a HTTP server'
  constructor: ->
    @protocol = ''
    @inPorts =
      server: new noflo.Port 'object'
      protocol: new noflo.Port 'string'
    @outPorts =
      connection: new noflo.Port 'object'
      url: new noflo.Port 'object'
      ip: new noflo.Port 'string'
      error: new noflo.Port 'object'

    @inPorts.server.on 'data', (webServer) =>
      @createSocketServer webServer

    @inPorts.protocol.on 'data', (@protocol) =>

  createSocketServer: (webServer) ->
    socketServer = new server
      httpServer: webServer
    socketServer.on 'request', @handleRequest

  handleRequest: (request) =>
    try
      connection = request.accept @protocol, request.origin
    catch err
      if @outPorts.error.isAttached()
        prots = request.requestedProtocols.join ', '
        err = new Error "Accepting #{@protocol} failed, requested #{prots}"
        @outPorts.error.send err
        @outPorts.error.disconnect()
        return
      throw err
    @outPorts.connection.beginGroup request.key
    @outPorts.connection.send connection
    @outPorts.connection.endGroup()
    @outPorts.connection.disconnect()

    if @outPorts.url.isAttached()
      @outPorts.url.beginGroup request.key
      @outPorts.url.send request.resourceURL
      @outPorts.url.endGroup()
      @outPorts.url.disconnect()
    if @outPorts.ip.isAttached()
      @outPorts.ip.beginGroup request.key
      @outPorts.ip.send request.remoteAddress
      @outPorts.ip.endGroup()
      @outPorts.ip.disconnect()

exports.getComponent = -> new ListenConnections

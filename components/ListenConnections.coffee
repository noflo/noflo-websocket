noflo = require 'noflo'
{server} = require 'websocket'

class ListenConnections extends noflo.Component
  constructor: ->
    @protocol = ''
    @inPorts =
      server: new noflo.Port 'object'
      protocol: new noflo.Port 'string'
    @outPorts =
      connection: new noflo.Port 'object'
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
    @outPorts.connection.send connection
    @outPorts.connection.disconnect()

exports.getComponent = -> new ListenConnections

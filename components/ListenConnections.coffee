noflo = require 'noflo'
{server} = require 'websocket'

class ListenConnections extends noflo.Component
  constructor: ->
    @protocol = 'noflo'
    @inPorts =
      server: new noflo.Port 'object'
      protocol: new noflo.Port 'string'
    @outPorts =
      connection: new noflo.Port 'object'

    @inPorts.server.on 'data', (webServer) =>
      @createSocketServer webServer

    @inPorts.protocol.on 'data', (@protocol) =>

  createSocketServer: (webServer) ->
    socketServer = new server
      httpServer: webServer
    socketServer.on 'request', @handleRequest

  handleRequest: (request) =>
    connection = request.accept @protocol, request.origin
    @outPorts.connection.send connection
    @outPorts.connection.disconnect()

exports.getComponent = -> new ListenConnections

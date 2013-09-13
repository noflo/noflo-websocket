noflo = require 'noflo'

class ListenMessages extends noflo.Component
  constructor: ->
    @inPorts =
      connection: new noflo.Port 'object'
    @outPorts =
      utf8: new noflo.Port 'string'
      binary: new noflo.Port 'binary'

    @inPorts.connection.on 'data', (data) ->
      @subscribe data

  subscribe: (connection) ->
    connection.on 'message', (message) =>
      if message.type is 'utf8'
        @outPorts.utf8.send message.utf8Data
        return
      if message.type is 'binary'
        @outPorts.binary.send message.binaryData
        return

    connection.on 'close', =>
      @outPorts.utf8.disconnect()
      @outPorts.binary.disconnect()

exports.getComponent = -> new ListenMessages

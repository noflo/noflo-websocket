noflo = require 'noflo'

class SendMessage extends noflo.Component
  constructor: ->
    @connection = null
    @buffer = []
    @keepBuffer = true
    @inPorts =
      connection: new noflo.Port 'object'
      string: new noflo.Port 'string'
      buffer: new noflo.Port 'boolean'
      clear: new noflo.Port 'bang'
    @outPorts =
      buffered: new noflo.Port 'int'

    @inPorts.connection.on 'data', (@connection) =>
      do @sendBuffer if @buffer.length

    @inPorts.string.on 'data', (data) =>
      return @send data if @connection
      return unless @keepBuffer
      @buffer.push data
      return unless @outPorts.buffered.isAttached()
      @outPorts.buffered.send @buffer.length

    @inPorts.buffer.on 'data', (data) =>
      @keepBuffer = String(data) is 'true'
      @buffer = [] unless @keepBuffer
      return unless @outPorts.buffered.isAttached()
      @outPorts.buffered.disconnect()

    @inPorts.clear.on 'data', =>
      do @clear
      return unless @outPorts.buffered.isAttached()
      @outPorts.buffered.send @buffer.length
      @outPorts.buffered.disconnect()

  send: (message) ->
    if noflo.isBrowser()
      @connection.send message
      return
    @connection.sendUTF message

  sendBuffer: ->
    @send message for message in @buffer
    @buffer = []
    return unless @outPorts.buffered.isAttached()
    @outPorts.buffered.send @buffer.length
    @outPorts.buffered.disconnect()

  clear: ->
    @buffer = []

exports.getComponent = -> new SendMessage

noflo = require 'noflo'
path = require 'path'
chai = require 'chai'
websocket = require 'websocket'
baseDir = path.resolve __dirname, '../'

describe 'WebSocket echo server', ->
  network = null
  port = 3337
  before (done) ->
    @timeout 6000
    graphPath = path.resolve __dirname, '../example/echoserver.fbp'
    noflo.loadFile graphPath,
      baseDir: baseDir
    , (err, nw) ->
      nw.start()
      network = nw
      done()
  describe 'after instantiation', ->
    it 'should be possible to run', (done) ->
      network.addInitial
        from:
          data: port
        to:
          node: 'Web'
          port: 'listen'
      , (err) ->
        return done err if err
        done()
  describe 'a websocket client', ->
    connection = null
    it 'should be able to connect to the server', (done) ->
      client = new websocket.client
      client.connect "ws://localhost:#{port}", 'test'
      client.on 'connect', (conn) ->
        connection = conn
        done()
      client.on 'connectFailed', done
    it 'should echo back what the client sends', (done) ->
      connection.on 'message', (msg) ->
        chai.expect(msg.type).to.equal 'utf8'
        chai.expect(msg.utf8Data).to.equal 'Hello world!'
        done()
      connection.sendUTF 'Hello world!'

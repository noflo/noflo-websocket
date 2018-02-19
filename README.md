# noflo-websocket [![Build Status](https://secure.travis-ci.org/noflo/noflo-websocket.png?branch=master)](http://travis-ci.org/noflo/noflo-websocket)

WebSocket components for NoFlo

## Changes

* 0.4.0 (February 19 2018)
  - Added basic authentication support for Node.js clients
  - Changed SendMessage to use a `control` port instead of internal state to fix potential race conditions

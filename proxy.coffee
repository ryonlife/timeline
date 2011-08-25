# Requirements
CONFIG = require('config').config
exec = require('child_process').exec
spawn = require('child_process').spawn
sys = require 'sys'
http = require 'http'
https = require 'https'
httpProxy = require 'http-proxy'
url = require 'url'
querystring = require 'querystring'
_ = require './brunch/src/vendor/underscore-1.1.7.js'
airbrake = require('airbrake').createClient 'fc48013989cadeb32a1a262a3dab7cb1'

# Globals
TOKEN = null
proxy = new httpProxy.HttpProxy()

# Handle otherwise uncaught exceptions
process.on 'uncaughtException', (e) ->
  console.error e.stack
  if CONFIG.name == 'production'
    airbrake.notify e
  else
    exec "growlnotify -m #{e}"

# Server responds with a known error
error = (response, error, reason, code) ->
  console.error "[Error #{code}]: #{error} (#{reason})"
  response.writeHead code, {'Content-Type': 'application/json'}
  response.write JSON.stringify({error, reason})
  response.end()

# Server responds with an unknown error
unknownError = (response, e) ->
  console.error e.stack
  error response, 'Unknown Error', 'An unknown error occured, was logged and will be looked into. Sorry about that!', 500

# Watch the coffescript source for this process and recompile if it changes, which will restart this server
exec 'coffee --watch --compile *.coffee'

# Spawn a process and buffer the output to the console and Growl
spawner = (processName, args, growlCondition) ->
  process = spawn processName, args
  processOut = (data) ->
    data = data.toString 'utf8'
    console.log "[#{processName}] #{data}"
    if CONFIG.name == 'development'
      growl = growlCondition data
      exec "growlnotify -m [#{processName}] #{growl}" if growl
  process.stdout.on 'data', (data) -> processOut data
  process.stderr.on 'data', (data) -> processOut data
  process.on 'exit', (code) -> console.log "[#{processName}] exited with code #{code}"

# Brunch
growlCondition = (data) -> if /Error/.test data then 'error' else 'compiled'
spawner 'brunch', ['watch'], growlCondition

# CouchApp
if CONFIG.name == 'development'
  growlCondition = (data) -> if /Finished push/.test data then data else false
  spawner 'couchapp', ['sync', 'couchapp.js', "#{CONFIG.target}#{CONFIG.prefix}"], growlCondition

# Proxy to handle requests
requestHandler = (request, response) ->
  parsedUrl = url.parse request.url
  if request.method == 'GET'
    request.url = '/timeline/_design/timeline/index.html' if parsedUrl.pathname == '/'
    hostAndPort = CONFIG.target.split('//')[1].split(':')
    proxy.proxyRequest request, response, {host: hostAndPort[0], port: hostAndPort[1]}
  else
    # Get the token from the cookie
    if request.headers.cookie
      cookies = request.headers.cookie.split ';'
      _.each cookies, (cookie) ->
        cookie = cookie.split '='
        TOKEN = cookie[1] if cookie[0] == 'access_token'
    # Logging
    console.log request.method
    console.log parsedUrl.pathname
    # Proxy
    parsedUrl.pathname = '/timeline/_design/timeline/index.html' if parsedUrl.pathname == '/'
    proxyUrl = "#{CONFIG.target}#{parsedUrl.pathname.substring CONFIG.prefix.length - 1}#{parsedUrl.search || ''}"
    authProxy request, response, url.parse(proxyUrl, true)

# Create the server
http.createServer(requestHandler).listen CONFIG.port
console.log "Proxy ready on port #{CONFIG.port}"

# Authenticates using Facebook, then proxies to CouchDB
authProxy = (inRequest, inResponse, proxyUrl) ->
  
  # Logging
  console.log "#{inRequest.method} #{proxyUrl}"
  
  # Construct the incoming request body
  inData = ''
  inRequest.on 'data', (chunk) ->
    inData += chunk
  
  # When the incoming request is finished, time to proxy it
  inRequest.on 'end', ->
    
    # Timer to check the status of a Facebook authorization
    authStarted = false
    authAttempt = setInterval ->
      
      if inRequest.method != 'GET' and not authStarted and not fbAuth.authenticated[TOKEN]
        # Request method requires authentication and user has not been authenticated, so need to authenticate before proxying
        authStarted = true
        fbAuth.authenticate TOKEN
      
      else if inRequest.method == 'GET' or (fbAuth.authenticated[TOKEN] and fbAuth.authenticated[TOKEN].fbId and fbAuth.authenticated[TOKEN].friends)
        # Time to proxy because this is a GET, which doesn't require authentication, or the user has been authenticated
        
        # Auth is finished, so kill the timer
        clearInterval authAttempt
        
        # Proxy headers
        headers = inRequest.headers  
        headers['host'] = "#{proxyUrl.hostname}:#{proxyUrl.port || 80}"
        headers['x-forwarded-for'] = inRequest.connection.remoteAddress
        headers['referer'] = "http://#{proxyUrl.hostname}:#{proxyUrl.port || 80}/"
        
        # Request to proxy
        outRequest = http.request
          host: proxyUrl.hostname
          port: proxyUrl.port
          path: "#{CONFIG.prefix}#{proxyUrl.pathname.substring 1}#{proxyUrl.search || ''}"
          method: inRequest.method
          headers: headers
        
        # Append Facebook data onto the querystring or request body before proxying the request
        # TODO
        params = querystring.parse inData
        outRequest.write inData

        outRequest.on 'error', (e) -> unknownError inResponse, e
        
        # Proxy response is coming back from CouchDB
        outRequest.on 'response', (outResponse) ->
          # Nginx does not support chunked transfers for proxied requests
          delete outResponse.headers['transfer-encoding']
          
          # Couch, where are ya?
          if outResponse.statusCode == 503
            return error inResponse, 'Database Unavailable', 'Database server not available.', 503

          # Construct the body of the response from CouchDB
          outResponse.on 'data', (chunk) -> inResponse.write chunk
          
          # CouchDB is done responding, so send that response back
          outResponse.on 'end', -> inResponse.end()
        
        # All event handlers have been bound to the proxy request, so end it to CouchDB
        outRequest.end()
            
      else if authStarted and not fbAuth.authenticated[TOKEN]
        # Authentication failed
        clearInterval authAttempt
        return error inResponse, 'Unauthorized', 'Facebook authentication failed.', 401
      
      # else, just wait a tenth of a second for the Facebook Graph API calls to return
    , 100

# Changes a Facebook token into a Facebook ID and verifies friend lists to prevent any funny business
fbAuth =
  # Key (token)/value (Facebook data) cache to store authenticated users
  authenticated: {}
  
  # Given a token, authenticate into Facebook and cache some key data
  authenticate: (token) ->
    # Cache
    fbAuth.authenticated[token] =
      fbId: null
      friends: []
      timestamp: new Date()
    
    # Get the user's Facebook ID
    me = fbAuth.callApi '/me', token, (me) ->
      fbAuth.authenticated[token].fbId = me.id if me
    
    # Get the user's friends
    friends = fbAuth.callApi '/me/friends', token, (friends) ->
      _.each friends.data, (friend) -> fbAuth.authenticated[token].friends.push friend.id if friends
  
  # Make a request to the Facebook API
  callApi: (url, token, success) ->
    request = https.request {host: 'graph.facebook.com', path: "#{url}?#{querystring.stringify {access_token: token}}"}, (response) ->
      # Piece the response together
      apiData = ''
      response.on 'data', (data) -> apiData += data.toString 'utf8'
      
      # API call has returned
      response.on 'end', ->
        if fbAuth.authenticated[token] and response.statusCode == 200
          # Return the parsed response
          success JSON.parse(apiData)
        else
          # Delete the cache key because there was an error response
          delete fbAuth.authenticate[token]
          console.error apiData
          null
    
    # Delete the cache key on any error
    request.on 'error', (e) ->
      delete fbAuth.authenticated[token]
      console.error e
    request.end()
  
  # Keeps the cache from getting stale
  expireCache: ->
    # Cached authenticated objects should not be older than an hour
    now = new Date()
    _.each fbAuth.authenticated, (a, i) -> fbAuth.authenticated.splice 0, i if a.timestamp - now < 3600000
    # Cache should not contain more than 50,000 keys (roughly 500MB of memory)
    fbAuth.authenticated.splice 0, 1 if fbAuth.authenticated.length > 50000

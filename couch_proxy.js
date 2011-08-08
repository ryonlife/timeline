if (process.argv[2] == 'production') {
  var ENV = 'production';
  var TARGET = 'http://app584241.heroku.cloudant.com:80';
  var USERNAME = 'meneveguentenerestakewhi';
  var PASSWORD = '4NmBXtNCpylinPauG5SEmSrV';
  var PREFIX = '/timeline/';
  var PORT = 5984;
  var ERROR = function(e) {
    sys.log(e.stack);
    Hoptoad.key = 'fc48013989cadeb32a1a262a3dab7cb1';
    Hoptoad.notify(e);
  };
} else {
  var ENV = 'development'
  var TARGET = 'http://localhost:5984';
  var USERNAME = '';
  var PASSWORD = '';
  var PREFIX = '/timeline/';
  var PORT = 8001;
  var ERROR = function(e) {
    sys.log(e.stack);
  };
}

var TOKEN = null;

var sys = require('sys');
var http = require('http');
var https = require('https');
var httpProxy = require('http-proxy');
var url = require('url');
var querystring = require('querystring');
var _ = require('./brunch/src/vendor/underscore-1.1.6.js');
var Hoptoad = require('./hoptoad_notifier').Hoptoad;

// Unhandled exceptions
process.on('uncaughtException', function(e) {
  ERROR(e);
});

var proxy = new httpProxy.HttpProxy();

// Server
function handleRequest(request, response) {
  var u = url.parse(request.url);
  
  if (request.headers.cookie) {
    var cookies = request.headers.cookie.split(';');
    _.each(cookies, function(cookie) {
      cookie = cookie.split('=');
      if (cookie[0] == 'access_token') {
        TOKEN = cookie[1];
      }
    });
  }
  
  // Only serve URLs that start with PREFIX
  if (u.pathname.substring(0, PREFIX.length) != PREFIX && u.pathname != '/') {
    return error(response, 'not found', 'Nothing found here.', 404);
  }
  
  uri = TARGET + u.pathname.substring(PREFIX.length-1) + (u.search || '');
  
  if (u.pathname.match(/^\/timeline\/_design\/timeline\//) || u.pathname == '/') {
    // Just getting static assets, so keep the proxying simple
    if (u.pathname == '/') {
      request.url = '/timeline/_design/timeline/index.html';
    }
    hostAndPort = TARGET.split('//')[1].split(':');
    proxy.proxyRequest(request, response, {
      host: hostAndPort[0],
      port: hostAndPort[1]
    });
  } else {
    // Homegrown proxy with Facebook authentication
    forwardRequest(request, response, uri);
  }
}
http.createServer(handleRequest).listen(PORT);
sys.puts('Proxy ready on port ' + PORT + '.');

// Authenticates using Facebook, then proxies to CouchDB
function forwardRequest(inRequest, inResponse, uri) {
  sys.log(inRequest.method + ' ' + uri);
  uri = url.parse(uri, true);
  
  // Construct the incoming request body
  var inData = ''
  inRequest.on('data', function(chunk) {
    inData += chunk;
    outRequest.write(chunk)
  });
  
  inRequest.on('end', function() {
    
    // Facebook authentication
    
    // Parse query string or request body
    if (inRequest.method == 'GET') {
      var params = uri.query;
    } else {
      var params = querystring.parse(inData);
    }

    if (uri.pathname.match(/^\/_design\/timeline\//)) {
        var authStarted = true;
        var skipAuth = true;
    } else {
        var authStarted = false;
    }
    
    var authAttempt = setInterval(function() {
      
      if (!skipAuth && !authStarted && !fbAuth.authenticated[TOKEN]) {
        // User has not been authenticated, so authenticate
        authStarted = true;
        fbAuth.authenticate(TOKEN);
      
      } else if (skipAuth || (fbAuth.authenticated[TOKEN] && fbAuth.authenticated[TOKEN].fbId && fbAuth.authenticated[TOKEN].friends)) {
        // User has been authenticated, so time to proxy
        clearInterval(authAttempt);
        
        var headers = inRequest.headers;  
        headers['host'] = uri.hostname + ':' + (uri.port || 80);
        headers['x-forwarded-for'] = inRequest.connection.remoteAddress;
        headers['referer'] = 'http://' + uri.hostname + ':' + (uri.port || 80) + '/';
        
        // Append Facebook data onto the querystring or request body before proxying the request
        
        // Proxy request
        if (uri.pathname === '/_uuids') {
          // Special case for UUID generation
          var path = '/_uuids' + uri.search || '';
        } else {
          var path = PREFIX + uri.pathname.substring(1) + uri.search || '';
        }
        var outRequest = http.request({
          host: uri.hostname,
          port: uri.port || 80,
          path: path,
          method: inRequest.method,
          headers: headers
        });

        outRequest.on('error', function(e) {
          unknownError(inResponse, e);
        });
        
        // Proxy response is coming back from CouchDB
        outRequest.on('response', function(outResponse) {
          // nginx does not support chunked transfers for proxied requests
          delete outResponse.headers['transfer-encoding'];
          
          if (outResponse.statusCode == 503) {
            return error(inResponse, 'database unavailable', 'Database server not available.', 503);
          }

          // Construct the body of the response from CouchDB
          outResponse.on('data', function(chunk) {
            inResponse.write(chunk);
          });
          
          // CouchDB is done responding, so send that response back
          outResponse.on('end', function() {
            inResponse.end();
          });

        });
        
        // All event handlers have been bound to the proxy request, so end it to CouchDB
        outRequest.end();
      
      } else if (authStarted && !fbAuth.authenticated[TOKEN]) {
        // Authentication failed
        clearInterval(authAttempt);
        return error(inResponse, 'unauthorized', 'Facebook authentication failed.', 401);
      }
      
      // else: just wait for Facebook Graph API calls to return
    }, 100);
  });
};

function error(response, error, reason, code) {
  sys.log('Error '+code+': '+error+' ('+reason+').');
  response.writeHead(code, {'Content-Type': 'application/json'});
  response.write(JSON.stringify({error: error, reason: reason}));
  response.end();
}

function unknownError(response, e) {
  sys.log(e.stack);
  error(response, 'unknown error', 'An unknown error occured, was logged and will be looked into. Sorry about that!', 500);
}

// Changes a Facebook token into a Facebook ID, and verifies friend lists, to prevent any funny business
var FbAuth = function() {
  var self = this;
  this.authenticated = {};
  
  this.authenticate = function(token) {
    self.authenticated[token] = {fbId: null, friends: null, timestamp: new Date()};
    
    // FB UID
    var dataMe = ''
    var reqMe = https.request({host: 'graph.facebook.com', path: '/me?'+querystring.stringify({access_token: token})}, function(res) {
      res.on('data', function(data) {
        dataMe += data.toString('utf8');
      });
      res.on('end', function() {
        dataMe = JSON.parse(dataMe);
        if (self.authenticated[token] && res.statusCode == 200) {
          // Succesful API calls
          self.authenticated[token].fbId = dataMe.id;
          console.log('Facebook user '+dataMe.id);
        } else {
          // API error
          delete self.authenticated[token];
          console.error(dataMe);
        }
      });
    });
    
    reqMe.on('error', function(e) {
      delete self.authenticated[token];
    });
    
    reqMe.end();
    
    // FB friends
    var dataFriends = ''
    var reqFriends = https.request({host: 'graph.facebook.com', path: '/me/friends?'+querystring.stringify({access_token: token})}, function(res) {      
      res.on('data', function(data) {
        dataFriends += data.toString('utf8');
      });
      res.on('end', function() {
        dataFriends = JSON.parse(dataFriends);
        if (self.authenticated[token] && res.statusCode === 200) {
          // Succesful API call
          var fbIds = [];
          for (var i = 0; i < dataFriends.data.length; i++) {
            fbIds.push(dataFriends.data[i].id);
          }
          self.authenticated[token].friends = fbIds;
          console.log('Facebook friend count '+fbIds.length);
        } else {
          // API error
          delete self.authenticated[token];
          console.error(dataFriends);
        }
        expireCache();
      });
    });
    
    reqFriends.on('error', function(e) {
      delete self.authenticated[token];
    });
    
    reqFriends.end();
  };
  
  function expireCache() {
    // Expire old authentication objects from the cache
    // Cached authenticated objects should not be older than an hour
    var now = new Date();
    for (var i = 0; i < self.authenticated.length; i++) {
      if (self.authenticated[i].timestamp - now < 3600000) {
        self.authenticated.splice(0, i);
        break;
      }
    }
    
    // Cache should not contain more than 50,000 keys (roughly 500MB of memory)
    if (self.authenticated.length > 50000) {
      self.authenticated.splice(0, 1);
    }
  }
};
var fbAuth = new FbAuth();

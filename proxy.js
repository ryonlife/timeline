(function() {
  var CONFIG, TOKEN, airbrake, authProxy, error, exec, fbAuth, growlCondition, http, httpProxy, https, proxy, querystring, requestHandler, spawn, spawner, sys, unknownError, url, _;
  CONFIG = require('config').config;
  exec = require('child_process').exec;
  spawn = require('child_process').spawn;
  sys = require('sys');
  http = require('http');
  https = require('https');
  httpProxy = require('http-proxy');
  url = require('url');
  querystring = require('querystring');
  _ = require('./brunch/src/vendor/underscore-1.1.7.js');
  airbrake = require('airbrake').createClient('fc48013989cadeb32a1a262a3dab7cb1');
  TOKEN = null;
  proxy = new httpProxy.HttpProxy();
  process.on('uncaughtException', function(e) {
    console.error(e.stack);
    if (CONFIG.name === 'production') {
      return airbrake.notify(e);
    } else {
      return exec("growlnotify -m " + e);
    }
  });
  error = function(response, error, reason, code) {
    console.error("[Error " + code + "]: " + error + " (" + reason + ")");
    response.writeHead(code, {
      'Content-Type': 'application/json'
    });
    response.write(JSON.stringify({
      error: error,
      reason: reason
    }));
    return response.end();
  };
  unknownError = function(response, e) {
    console.error(e.stack);
    return error(response, 'Unknown Error', 'An unknown error occured, was logged and will be looked into. Sorry about that!', 500);
  };
  exec('coffee --watch --compile *.coffee');
  spawner = function(processName, args, growlCondition) {
    var process, processOut;
    process = spawn(processName, args);
    processOut = function(data) {
      var growl;
      data = data.toString('utf8');
      console.log("[" + processName + "] " + data);
      if (CONFIG.name === 'development') {
        growl = growlCondition(data);
        if (growl) {
          return exec("growlnotify -m [" + processName + "] " + growl);
        }
      }
    };
    process.stdout.on('data', function(data) {
      return processOut(data);
    });
    process.stderr.on('data', function(data) {
      return processOut(data);
    });
    return process.on('exit', function(code) {
      return console.log("[" + processName + "] exited with code " + code);
    });
  };
  growlCondition = function(data) {
    if (/Error/.test(data)) {
      return 'error';
    } else {
      return 'compiled';
    }
  };
  spawner('brunch', ['watch'], growlCondition);
  if (CONFIG.name === 'development') {
    growlCondition = function(data) {
      if (/Finished push/.test(data)) {
        return data;
      } else {
        return false;
      }
    };
    spawner('couchapp', ['sync', 'couchapp.js', "" + CONFIG.target + CONFIG.prefix], growlCondition);
  }
  requestHandler = function(request, response) {
    var cookies, hostAndPort, parsedUrl, proxyUrl;
    parsedUrl = url.parse(request.url);
    if (request.method === 'GET') {
      console.log("" + request.method + " " + parsedUrl.pathname);
      if (parsedUrl.pathname === '/') {
        request.url = '/timeline/_design/timeline/index.html';
      }
      hostAndPort = CONFIG.target.split('//')[1].split(':');
      return proxy.proxyRequest(request, response, {
        host: hostAndPort[0],
        port: hostAndPort[1]
      });
    } else {
      if (request.headers.cookie) {
        cookies = request.headers.cookie.split(';');
        _.each(cookies, function(cookie) {
          cookie = cookie.split('=');
          if (cookie[0] === 'access_token') {
            return TOKEN = cookie[1];
          }
        });
      }
      if (parsedUrl.pathname === '/') {
        parsedUrl.pathname = '/timeline/_design/timeline/index.html';
      }
      proxyUrl = "" + CONFIG.target + (parsedUrl.pathname.substring(CONFIG.prefix.length - 1)) + (parsedUrl.search || '');
      return authProxy(request, response, url.parse(proxyUrl, true));
    }
  };
  http.createServer(requestHandler).listen(CONFIG.port);
  console.log("Proxy ready on port " + CONFIG.port);
  authProxy = function(inRequest, inResponse, proxyUrl) {
    var inData;
    inData = '';
    inRequest.on('data', function(chunk) {
      return inData += chunk;
    });
    return inRequest.on('end', function() {
      var authAttempt, authStarted;
      console.log("" + inRequest.method + " " + proxyUrl.pathname + " " + inData);
      authStarted = false;
      return authAttempt = setInterval(function() {
        var headers, outRequest, params;
        if (inRequest.method !== 'GET' && !authStarted && !fbAuth.authenticated[TOKEN]) {
          authStarted = true;
          return fbAuth.authenticate(TOKEN);
        } else if (inRequest.method === 'GET' || (fbAuth.authenticated[TOKEN] && fbAuth.authenticated[TOKEN].fbId && fbAuth.authenticated[TOKEN].friends)) {
          clearInterval(authAttempt);
          headers = inRequest.headers;
          headers['host'] = "" + proxyUrl.hostname + ":" + (proxyUrl.port || 80);
          headers['x-forwarded-for'] = inRequest.connection.remoteAddress;
          headers['referer'] = "http://" + proxyUrl.hostname + ":" + (proxyUrl.port || 80) + "/";
          outRequest = http.request({
            host: proxyUrl.hostname,
            port: proxyUrl.port,
            path: "" + CONFIG.prefix + (proxyUrl.pathname.substring(1)) + (proxyUrl.search || ''),
            method: inRequest.method,
            headers: headers
          });
          params = querystring.parse(inData);
          outRequest.write(inData);
          outRequest.on('error', function(e) {
            return unknownError(inResponse, e);
          });
          outRequest.on('response', function(outResponse) {
            delete outResponse.headers['transfer-encoding'];
            if (outResponse.statusCode === 503) {
              return error(inResponse, 'Database Unavailable', 'Database server not available.', 503);
            }
            outResponse.on('data', function(chunk) {
              return inResponse.write(chunk);
            });
            return outResponse.on('end', function() {
              return inResponse.end();
            });
          });
          return outRequest.end();
        } else if (authStarted && !fbAuth.authenticated[TOKEN]) {
          clearInterval(authAttempt);
          return error(inResponse, 'Unauthorized', 'Facebook authentication failed.', 401);
        }
      }, 100);
    });
  };
  fbAuth = {
    authenticated: {},
    authenticate: function(token) {
      var friends, me;
      fbAuth.authenticated[token] = {
        fbId: null,
        friends: [],
        timestamp: new Date()
      };
      me = fbAuth.callApi('/me', token, function(me) {
        if (me) {
          return fbAuth.authenticated[token].fbId = me.id;
        }
      });
      return friends = fbAuth.callApi('/me/friends', token, function(friends) {
        return _.each(friends.data, function(friend) {
          if (friends) {
            return fbAuth.authenticated[token].friends.push(friend.id);
          }
        });
      });
    },
    callApi: function(url, token, success) {
      var request;
      request = https.request({
        host: 'graph.facebook.com',
        path: "" + url + "?" + (querystring.stringify({
          access_token: token
        }))
      }, function(response) {
        var apiData;
        apiData = '';
        response.on('data', function(data) {
          return apiData += data.toString('utf8');
        });
        return response.on('end', function() {
          if (fbAuth.authenticated[token] && response.statusCode === 200) {
            return success(JSON.parse(apiData));
          } else {
            delete fbAuth.authenticate[token];
            console.error(apiData);
            return null;
          }
        });
      });
      request.on('error', function(e) {
        delete fbAuth.authenticated[token];
        return console.error(e);
      });
      return request.end();
    },
    expireCache: function() {
      var now;
      now = new Date();
      _.each(fbAuth.authenticated, function(a, i) {
        if (a.timestamp - now < 3600000) {
          return fbAuth.authenticated.splice(0, i);
        }
      });
      if (fbAuth.authenticated.length > 50000) {
        return fbAuth.authenticated.splice(0, 1);
      }
    }
  };
}).call(this);

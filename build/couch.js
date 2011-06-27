var httpProxy = require('http-proxy');
var url = require('url');
var fs = require('fs');
var https = require('https');
var querystring = require('querystring');

// process.on('uncaughtException', function (err) {
//   console.error(err);
// });

var Render = function() {
  // Renders files to the browser, with simple in-memory caching
  
  var cache = {};
  
  this.file = function(file, res) {
    self = this;
    
    if (cache[file]) {
      // Serve a file from memory
      res.writeHead(200, {'Content-Type': cache[file].contentType});
      res.end(cache[file].data, cache[file].encoding);
    } else {
      // First time serving a file, so cache it
      
      // Determine content type and encoding
      var fileParts = file.split('.');
      var fileType = fileParts[fileParts.length - 1];
      var utf8 = ['html', 'js', 'css'];
      var encoding = 'binary';
      for (var i=0; i<utf8.length; i++) {
        if (utf8[i] == fileType) {
          encoding = 'utf8';
          break;
        }
      }
      var contentTypes = {
        html: 'text/html',
        js: 'text/javascript',
        css: 'text/css',
        png: 'image/png',
        gif: 'image/gif',
        jpg: 'image/jpeg'
      };
      var contentType = contentTypes[fileType];
      
      // Read file from file system
      fs.readFile(file, encoding, function(err, data) {
        if (err) {
          // Couldn't find it, so respond with a 404
          res.writeHead(404);
          res.end();
        } else {
          // Cache the file and recursively call Render.file() to serve it
          cache[file] = {data: data, encoding: encoding, contentType: contentType};
          self.file(file, res);
        }
      });
    }
  };
};

var FbAuth = function() {
  // Changes a Facebook token into a Facebook ID, and verifies friend lists, to prevent any funny business
  
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
          console.error(data);
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
          console.error(data);
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
    var oldestSurvivor = null;
    for (var i = 0; i < self.authenticated.length; i++) {
      if (self.authenticated[i].timestamp - now < 3600000) {
        oldestSurvivor = i;
        break;
      }
    }
    if (oldestSurvivor) {
      self.authenticated.splice(0, oldestSurvivor);
    }
    
    // Cache should not contain more than 25,000 keys
    if (self.authenticated.length > 25000) {
      self.authenticated.splice(0, 1);
    }
  }
};

var render = new Render();
var fbAuth = new FbAuth();

httpProxy.createServer(function(req, res, proxy) {
  var path = url.parse(req.url).pathname;
  
  if (path == '/' || path == '/index.html') {
    // Root index.html file that will initialize Backbone.js
    render.file('index.html', res);
    
  } else if (path.search(/\/web\//) == 0) {
    // JS, CSS and image assets
    render.file(path.substr(1), res);
  
  } else {
    // Everything else should be proxied to CouchDB
    var token = '121822724510409%257C2.AQAGHhmq6zI4uAE9.3600.1309194000.1-569255561%257CqcWeHy5mbzN56S1TTZIQuByi36g';
    var authStarted = false;
    var authAttempt = setInterval(function() {
      if (!authStarted && !fbAuth.authenticated[token]) {
        // User has not been authenticated
        console.log('Authenticating...');
        authStarted = true;
        fbAuth.authenticate(token);

      } else if (fbAuth.authenticated[token] && fbAuth.authenticated[token].fbId && fbAuth.authenticated[token].friends) {
        // User has been authenticated
        console.log('Proxying...');
        clearInterval(authAttempt);
        res.writeHead(200);
        res.end();
        // proxy.proxyRequest(req, res, {host: 'localhost', port: 5984});

      } else if (authStarted && !fbAuth.authenticated[token]) {
        // Authentication failed
        clearInterval(authAttempt);
        res.writeHead(401);
        res.end();
      }
      
      // else: just wait for Facebook Graph API calls to return
    }, 100);
  }
}).listen(8000);
console.log('CouchDB proxy running at http://localhost:8000/');

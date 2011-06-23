var httpProxy = require('http-proxy');
var url = require('url');
var fs = require('fs');
var https = require('https');
var querystring = require('querystring');

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
    proxy.proxyRequest(req, res, {
      host: 'localhost',
      port: 5984
    });
  }
}).listen(8000);
console.log('CouchDB proxy running at http://localhost:8000/');

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
          console.log(file);
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

var render = new Render();

// d = new Date();
// cache[token] = {fb_uid: '123', fb_friends_uids: [], timestamp: d.getTime()}
// https://graph.facebook.com/me/friends?access_token=
// {"data":[{"name":"Mike Baria","id":"15548"}, ...

var params = {access_token: '121822724510409|2.AQA5MBhgtAvl1IQF.3600.1308848400.1-569255561|7DCPSnWY1w_8v5_V64CYjcpz-vQ'};
var options = {host: 'graph.facebook.com', path: '/me/friends?'+querystring.stringify(params)};
var options = {host: 'graph.facebook.com', path: '/me?'+querystring.stringify(params)};
var req = https.request(options, function(res) {
  res.on('data', function(data) {
    console.log(data.toString('utf8'));
  });
});
req.end();
req.on('error', function(e) {
  console.error(e);
});

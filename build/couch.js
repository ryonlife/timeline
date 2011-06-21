var httpProxy = require('http-proxy');
var url = require('url');
var fs = require('fs');

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

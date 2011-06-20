var httpProxy = require('http-proxy');
httpProxy.createServer(function(req, res, proxy) {
  console.log(req);
  if (req.url == '/') {
    console.log('balls');
  } else {
    proxy.proxyRequest(req, res, {
      host: 'localhost',
      port: 5984
    });
  }
}).listen(8000);

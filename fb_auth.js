var http = require('http');
var cache = {}

http.createServer(function (req, res) {
  d = new Date();
  cache[token] = {fb_uid: '123', fb_friends_uids: [], timestamp: d.getTime()}
  
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Hello World\n');
  console.log(res)
}).listen(8000, '127.0.0.1');

console.log('Server running at http://127.0.0.1:8000/');

// /usr/local/etc/couchdb/local.ini
// https://graph.facebook.com/me/friends?access_token=
// {"data":[{"name":"Mike Baria","id":"15548"}, ...

var util = require('util');
var path = require('path');
var port = process.argv[2];

var express = require("express");
var app = express.createServer();

var buildPath = path.join(process.argv[3], 'build');

app.configure(function(){
    app.set('views', buildPath);
    app.use(express.static(buildPath));
});

app.get('/', function(req, res){
  res.render('index');
});

util.log("starting server on port " + port);
app.listen(parseInt(port, 10));


httpProxy = require('http-proxy');
var proxy = new httpProxy.HttpProxy();
app.get('/couchdb/*', function(req, res){
  res.render('index');
  // proxy.proxyRequest(req, res, {
  //   host: 'google.com',
  //   port: 80
  // });
});

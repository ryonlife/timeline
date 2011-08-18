window.CONFIG = require('lib/config').config

if CONFIG.hoptoadApiKey
  $.getScript 'http://hoptoadapp.com/javascripts/notifier.js', ->
    Hoptoad.setKey(CONFIG.hoptoadApiKey)

Backbone.couch_connector.config.db_name = 'timeline'
Backbone.couch_connector.config.ddoc_name = 'timeline'
Backbone.couch_connector.config.global_changes = false
Backbone.couch_connector.viewName = 'collection'

window.Helpers = require('lib/helpers').helpers

HomeRouter = require('routers/home_router').HomeRouter
MemoriesRouter = require('routers/memories_router').MemoriesRouter

$(document).ready ->
  initialize = ->    
    e = document.createElement 'script'
    e.async = true
    e.src = "#{document.location.protocol}//connect.facebook.net/en_US/all.js"
    document.getElementById('fb-root').appendChild e
  
  initialize()
  
window.fbAsyncInit = ->
  FB.init {appId: '121822724510409', status: true, cookie: true, xfbml: true}
  FB.Canvas.setAutoResize()
  
  window.USER = {}
  FB.api '/me', (response) -> USER.ME = response
  FB.api '/me/friends', (response) -> USER.FRIENDS = response
  FB.api '/me/albums', (response) -> USER.ALBUMS = response
  
  bootstrap = ->
    new HomeRouter
    new MemoriesRouter
    Backbone.history.start()
  
  fbComplete = null
  FbComplete = setInterval ->
    if USER.ME and USER.FRIENDS and USER.ALBUMS
      clearInterval FbComplete
      bootstrap()
  , 50
  
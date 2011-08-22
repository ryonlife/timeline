window.CONFIG = require('lib/config').config

if CONFIG.hoptoadApiKey
  $.getScript 'http://hoptoadapp.com/javascripts/notifier.js', ->
    Hoptoad.setKey(CONFIG.hoptoadApiKey)

require('lib/view')
window.Helpers = require('lib/helpers').Helpers

Backbone.couch_connector.config.db_name = 'timeline'
Backbone.couch_connector.config.ddoc_name = 'timeline'
Backbone.couch_connector.config.global_changes = false
Backbone.couch_connector.viewName = 'collection'

HomeRouter = require('routers/home_router').HomeRouter
MemoriesRouter = require('routers/memories_router').MemoriesRouter

$(document).ready ->
  
  window.USER = {}
  
  window.bootstrap = ->
    new HomeRouter
    new MemoriesRouter    
    Backbone.history.start()
  
  $.getScript "#{document.location.protocol}//connect.facebook.net/en_US/all.js"
  
  window.fbAsyncInit = ->
    FB.init {appId: '121822724510409', status: true, cookie: true, xfbml: true}
    FB.Canvas.setAutoResize()
  
    fbComplete = null
    FbComplete = setInterval ->
      if USER.ME and USER.FRIENDS and USER.ALBUMS
        USER.AUTH = if USER.ME.error or USER.FRIENDS.error or USER.ALBUMS.error then false else true
        clearInterval FbComplete
        bootstrap()
    , 50
    
    FB.api '/me', (response) -> USER.ME = response
    FB.api '/me/friends', (response) -> USER.FRIENDS = response
    FB.api '/me/albums', (response) -> USER.ALBUMS = response
  
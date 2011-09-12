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
  
  $('.login_button').live 'click', (e) -> $.cookie 'hash', document.location.hash
  
  window.bootstrap = ->
    new HomeRouter
    new MemoriesRouter
    Backbone.history.start()
    
    # On Facebook's OAuth page, user did not allow requested permissions,
    # so redirect back to the page they were viewing, deleting the access_token cookie so they're not logged in
    error = $.url().param 'error'
    if error == 'access_denied'
      $.cookie 'access_token', null
      hash = $.cookie 'hash'
      location.href = if hash then "#{location.origin}#{hash}" else "#{location.origin}"
  
  $.getScript "#{document.location.protocol}//connect.facebook.net/en_US/all.js"
  
  window.fbAsyncInit = ->
    FB.init {appId: '121822724510409', status: true, cookie: true, xfbml: true}
    FB.Canvas.setAutoResize()
    
    FB.getLoginStatus (loginStatusResponse) ->
      if loginStatusResponse.status != 'connected'
        # User has not authorized Timeline to connect to his Facebook account
        USER.AUTH = false
        $.cookie 'access_token', null
        bootstrap()
      else
        # User did authorize Timeline
        fbComplete = null
        FbComplete = setInterval ->
          if USER.ME and USER.FRIENDS and USER.ALBUMS
            if USER.ME.error or USER.FRIENDS.error or USER.ALBUMS.error
              USER.AUTH = false
              $.cookie 'access_token', null
            else
              USER.AUTH = true
              $.cookie 'access_token', loginStatusResponse.session.access_token
            # Now that Facebook auth status is a known commodity, app can be started
            clearInterval FbComplete
            bootstrap()
        , 50
        
        FB.api '/me', (response) -> USER.ME = response
        FB.api '/me/friends', (response) -> USER.FRIENDS = response
        FB.api '/me/albums', (response) -> USER.ALBUMS = response
  
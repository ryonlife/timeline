HomeView = require('views/home/home_view').HomeView

class exports.HomeRouter extends Backbone.Router
  routes:
    '': 'home'
    '!/oauth': 'oauth'
    'access_token=:params': 'access_token'

  constructor: ->
    super

  home: ->
    view = new HomeView
    $('#fb_wrapper').html view.render().el
  
  oauth: ->
    top.location = "http://www.facebook.com/dialog/oauth/?scope=user_birthday,user_photo_video_tags,user_photos&client_id=121822724510409&redirect_uri=#{CONFIG.url}&response_type=token"
      
  access_token: (params) ->
    hash = $.cookie 'hash'
    location.hash = if hash then hash else '#'
    location.reload()
    

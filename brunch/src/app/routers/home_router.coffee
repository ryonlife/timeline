HomeIndexView = require('views/home/home_index_view').HomeIndexView

class exports.HomeRouter extends Backbone.Router
  routes:
    '': 'oauth'
    'access_token=:params': 'access_token'
    '!/home': 'home_index'

  constructor: ->
    super

  home_index: ->
    view = new HomeIndexView
    $('#fb_wrapper').html view.render().el
  
  oauth: ->
    error = $.url().param 'error'
    if error == 'access_denied'
      $.cookie 'access_token', null
    else
      top.location = "http://www.facebook.com/dialog/oauth/?scope=user_birthday,user_photo_video_tags,user_photos&client_id=121822724510409&redirect_uri=#{CONFIG.url}&response_type=token"
      
  access_token: (params) ->
    params = params.split '&expires_in='
    $.cookie 'access_token', params[0]
    location.hash = '!/memories'
    
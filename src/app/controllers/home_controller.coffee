class exports.HomeController extends Backbone.Controller
  routes :
    "home": "home"

  constructor: ->
    super

  home: ->
    $('#fb_wrapper').html app.views.home_index.render().el

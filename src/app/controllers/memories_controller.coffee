class exports.MemoriesController extends Backbone.Controller
  routes:
    '/memories/new': 'new'

  constructor: ->
    super

  new: ->
    $('#fb_wrapper').html app.views.memories_new.render().el
    
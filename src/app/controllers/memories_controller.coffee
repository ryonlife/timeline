class exports.MemoriesController extends Backbone.Controller
  routes:
    '/memories/:id': 'show'

  constructor: ->
    super
        
  show: ->
    $('#fb_wrapper').html app.views.memories_show.render().el
    app.views.memories_show.datepickers()
  
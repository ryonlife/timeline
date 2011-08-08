class exports.MemoriesController extends Backbone.Controller
  routes:
    '/memories/new': 'new'
    '/memories/:id': 'show'

  # new: ->
  #   http://127.0.0.1:5984/_uuids

  show: ->
    id = location.hash.split('/')[2]
    app.views.memories_show.model = new app.models.memory {id}
    $('#fb_wrapper').html app.views.memories_show.render().el
    app.views.memories_show.datepickers()
    
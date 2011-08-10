class exports.MemoriesRouter extends Backbone.Router
  routes:
    '!/memories/new': 'new'
    '!/memories/:id': 'show'
  
  new: ->
    $('#fb_wrapper').html app.views.memories_show.renderTest().el

  show: ->
    id = location.hash.split('/')[2]
    app.views.memories_show.model = new app.models.memory {id}
    $('#fb_wrapper').html app.views.memories_show.render().el
    app.views.memories_show.datepickers()
    
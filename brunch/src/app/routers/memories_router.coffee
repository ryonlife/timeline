class exports.MemoriesRouter extends Backbone.Router
  routes:
    '!/memories/:id': 'show'
  
  show: ->
    id = location.hash.split('/')[2]
    
    app.views.memories_show.model = if id == 'new'
      new app.models.memory {owner: USER.ME.id}
    else
      new app.models.memory {id}
    
    $('#fb_wrapper').html app.views.memories_show.render().el
    app.views.memories_show.datepickers()
    
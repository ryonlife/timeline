class exports.MemoriesController extends Backbone.Controller
  routes:
    '/memories/new' : 'new'
    '/memories/:id' : 'show'

  constructor: ->
    super

  new: ->
    $('#fb_wrapper').html(app.views.memories_new.render().el)
    
    # Cheat for top-aligning stuff
    $('#fb_wrapper').find('[data-top-align-with]').each(->
      $this = $(this)
      console.log($this)
    )
    
  show: ->
    $('#fb_wrapper').html(app.views.memories_show.render().el)
    
    # Cheat for centering stuff
    $('#fb_wrapper').find('.center_cheat').each(->
      $this = $(this)
      $this.css({'width': $this.width(), 'display': 'block'})
    )
  
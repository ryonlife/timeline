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
      $alignWith = $($this.attr('data-top-align-with'))
      $this.css({'position': 'relative', top: $alignWith.position().top - $this.position().top})
    )
    
  show: ->
    $('#fb_wrapper').html app.views.memories_show.render().el
    $('#add_photos').trigger('click')
    $.centerCheat()
  
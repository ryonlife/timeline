class exports.MemoriesController extends Backbone.Controller
  routes:
    '/memories/:id': 'show'

  constructor: ->
    super
        
  show: ->
    $('#fb_wrapper').html app.views.memories_show.render().el
    app.views.memories_show.datepickers()
    # app.views.memories_show.tutorial()
    
    # latlng = new google.maps.LatLng(-34.397, 150.644);
    # myOptions =
    #   zoom: 8
    #   center: latlng
    #   mapTypeId: google.maps.MapTypeId.ROADMAP
    # map = new google.maps.Map(document.getElementById("map_canvas"), myOptions)
    
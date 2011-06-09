class exports.MemoriesController extends Backbone.Controller
  routes:
    '/memories/:id': 'show'

  show: ->
    id = location.hash.split('/')[2]
    app.views.memories_show.model = new app.models.memory {id}
    $('#fb_wrapper').html app.views.memories_show.render().el
    app.views.memories_show.datepickers()
    
    # latlng = new google.maps.LatLng(-34.397, 150.644);
    # myOptions =
    #   zoom: 8
    #   center: latlng
    #   mapTypeId: google.maps.MapTypeId.ROADMAP
    # map = new google.maps.Map(document.getElementById("map_canvas"), myOptions)
    
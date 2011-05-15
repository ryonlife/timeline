memoriesShowTemplate = require('templates/memories/memories_show')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show'
  
  events:
    'click #tag_friends': 'showFriendSelector'
    'click #show_photos': 'showPhotos'
    'click .add_photos': 'showPhotoSelector'
    'click .fb_gallery': 'showGallery'
  
  render: ->
    $view = $(@.el).html memoriesShowTemplate()
    $view.find('#photos').after app.views.memories_show_photo_selector.render().el
    @
    
  showFriendSelector: (e) ->
    e.preventDefault()
    FB.api '/me/friends', (response) -> $.fbFriendSelector(response.data)
    
  showPhotos: (e) ->
    e.preventDefault()
    $(e.currentTarget).remove()
    $('#photos span').removeClass('hide').hide().fadeIn()
  
  showPhotoSelector: (e) ->
    e.preventDefault()
    $ps = $('#photo_selector_view')
    if $ps.is(':visible')
      $ps.fadeOut()
    else
      app.views.memories_show_photo_selector.reset()
      $ps.fadeIn()
        
  showGallery: (e) ->
    e.preventDefault()
    $pic = $(e.target)
    $pic.fbGallery()
    
memoriesShowTemplate = require('templates/memories/memories_show')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show'
  
  events:
    'click a#tag_friends': 'showFriendSelector'
    'click a#show_photos': 'showPhotos'
    'click a.add_photos': 'showPhotoSelector'
    'click a.fb_gallery': 'showGallery'
    'click a.fb_gallery label': 'removePhoto'
  
  render: ->
    $view = $(@.el).html memoriesShowTemplate()
    $view.find('#photos').after app.views.memories_show_photo_selector.render().el
    @
    
  showFriendSelector: (e) ->
    e.preventDefault()
    FB.api '/me/friends', (response) -> $.fbFriendSelector(response.data)
    
  showPhotos: (e) ->
    e.preventDefault()
    $el = $(e.currentTarget)
    $p = $('#photos li')
    if $p.length > 5 and $p.filter(':visible').length < $p.length
      $el.text('Hide Photos')
      $('#photos li').fadeIn()
    else
      $el.text('Show All Photos ('+$p.find('a.fb_gallery').length+')')
      $('#photos li:gt(4)').fadeOut()
  
  showPhotoSelector: (e) ->
    e.preventDefault()
    $add = $('#add_photos')
    $ps = $('#photo_selector_view')
    if $ps.is(':visible')
      $add.text('Add Photos')
      $ps.fadeOut()
    else
      app.views.memories_show_photo_selector.reset()
      $add.text('Close')
      $ps.fadeIn()
        
  showGallery: (e) ->
    e.preventDefault()
    $pic = $(e.target)
    $pic.fbGallery() if $pic.filter('a').length # Do not open the gallery if the close button was clicked
    
  removePhoto: (e) ->
    $(e.currentTarget).parents('li')
      .css('background', '#ECEFF5')
      .html('')
      
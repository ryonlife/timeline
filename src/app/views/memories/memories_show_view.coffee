memoriesShowTemplate = require('templates/memories/memories_show')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show'
  
  events:
    'click #tag_friends' : 'showFriendSelector'
    'click .fb_gallery'  : 'showGallery'
    'click #show_photos' : 'showPhotos'
  
  render: ->
    $view = $(@.el).html(memoriesShowTemplate())
    
    # Show the number of tagged friends on the Tag Friends buttons
    friends = [{'id': 1, 'name': 'Ryan McKillen'}]
    $view.find('#tag_friends').html('<span class="tag"></span> Tag Friends ('+parseInt(friends.length)+')') if friends.length
    
    @
    
  showFriendSelector: (e) ->
    e.preventDefault()
    $.fbFriendSelector(ME.friends)
    
  showGallery: (e) ->
    e.preventDefault()
    
    $pic = $(e.target)
    $pic.fbGallery()
    
  showPhotos: (e) ->
    e.preventDefault()
    $(e.currentTarget).remove()
    $('#photos span').removeClass('hide').hide().fadeIn(1000)
    
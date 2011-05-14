memoriesShowTemplate = require('templates/memories/memories_show')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show'
  
  events:
    'click #tag_friends': 'showFriendSelector'
    'click .fb_gallery': 'showGallery'
    'click #show_photos': 'showPhotos'
    
    # Photo selector
    'click .add_photos': 'photoSelectorShow'
    'click #select_from_container a': 'photoSelectorPickSource'
    'click #select_from_albums': 'photoSelectorShowAlbums'
  
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
    $('#photos span').removeClass('hide').hide().fadeIn()
  
  photoSelectorShow: (e) ->
    e.preventDefault()
    $ps = $('#photo_selector')
    if $ps.is(':visible')
      $ps.fadeOut()
    else
      this.photoSelectorReset()
      $ps.fadeIn()
    
  photoSelectorPickSource: (e) ->
    e.preventDefault()
    $link = $(e.currentTarget)
    if not $link.hasClass('selected')
      this.photoSelectorReset()
      $link.parent().addClass('selected')
      $('#photo_choices').show()
  
  photoSelectorShowAlbums: (e) ->
    e.preventDefault()
    $link = $(e.currentTarget)
    $link.hide().siblings().show()
    $.centerCheat()
    
  photoSelectorReset: (e) ->
    $('#select_from_container')
      .find('div').removeClass('selected').end()
      .find('a').show().end()
      .find('select').hide().find('option:first').attr('selected', 'selected').end().end()
      .find('#photo_choices').hide()
    
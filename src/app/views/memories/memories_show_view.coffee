memoriesShowTemplate = require('templates/memories/memories_show')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show'
  page: 2
  maxReached: false
  pendingRequest: false
  
  events:
    'click #tag_friends': 'showFriendSelector'
    'click .fb_gallery': 'showGallery'
    'click #show_photos': 'showPhotos'
    # Photo selector
    'click .add_photos': 'photoSelectorShow'
    'click #select_from_container a': 'photoSelectorPickSource'
    'click #select_from_albums': 'photoSelectorShowAlbums'
    'click #select_from_tagged': 'photoSelectorShowTaggedPhotos'
    'scroll #photo_choices ul': 'infinityScroll'
  
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
      
  photoSelectorShowTaggedPhotos: (e) ->
    $('#photo_choices').show()
    
    i = 0
    for photo in ME.photos.data
      for image in photo.images
        if image.width <= 180
          $photo = $('<li></li>').css('background', '#000 url('+image.source+') no-repeat center center')
          $photo.addClass('middle') if i == 1
          $('#photo_choices ul').append($photo)
          i = if i == 2 then 0 else i + 1
          break
    
    @.delegateEvents()
    
    $('#photo_choices ul').scroll (e) =>
      this.infinityScroll(e)

  infinityScroll: (e) ->
    $el = $(e.currentTarget)
    if 140 >= $(document).height() - $el.height() - $el.scrollTop() and not this.pendingRequest
      this.pendingRequest = true
      FB.api '/me/photos', {limit: 60, offset: (this.page - 1) * 60}, (response) ->
        for photo in response.data
          for image in photo.images
            if image.width <= 180
              $photo = $('<li></li>').css('background', '#000 url('+image.source+') no-repeat center center')
              $('#photo_choices ul').append($photo)
              break
        if response.paging && response.paging.next
          this.page++
        else
          this.maxReached = true
        this.pendingRequest = false
    
memoriesShowPhotoSelectorTemplate = require('templates/memories/memories_show_photo_selector')

class exports.MemoriesShowPhotoSelectorView extends Backbone.View
  id: 'photo_selector_view'
  
  state:
    limit: 60
    page: 1
    maxReached: false
    pendingRequest: false
  
  events:
    'click #select_from_container a': 'selectSource'
    'click #select_from_albums': 'showAlbums'
    'click #select_from_tagged': 'showTaggedPhotos'
    'change select': 'showAlbumPhotos'
  
  render: ->
    $(@el).html memoriesShowPhotoSelectorTemplate()
    @
    
  selectSource: (e) ->
    e.preventDefault()
    $el = $(e.currentTarget)
    if not $el.hasClass('selected')
      @reset()
      $el.parent().addClass('selected')
  
  showAlbums: (e) ->
    e.preventDefault()
    $(e.currentTarget).hide().siblings().show()
    $.centerCheat()
          
  showTaggedPhotos: (e) ->
    $('#photo_choices')
      .show()
      .find('ul')
        .scroll (e) =>
          @infinityScroll(e) # Binding a listender to the the scroll event Backbone-style doesn't work
          @
        .trigger('scroll')

  infinityScroll: (e) ->    
    $el = $(e.currentTarget)
    if (@state.page == 1 or 700 >= Math.ceil($el.find('li').length / 3) * 140 - $el.scrollTop()) and not @state.pendingRequest and not @state.maxReached
      
      @state.pendingRequest = true  
      FB.api '/me/photos', {limit: @state.limit, offset: (@state.page - 1) * @state.limit}, (response) =>
    
        console.log('api '+(@state.page - 1) * @state.limit)

        for photoList in response.data
          for photo in photoList.images
            if photo.width <= 180
              $photo = $('<li></li>').css('background', '#000 url('+photo.source+') no-repeat center center')
              $('#photo_choices ul').append($photo)
              break
      
        $('#photo_choices ul li:nth-child(3n+2)').addClass('middle')
      
        if response.paging && response.paging.next
          @state.page++
        else
          @state.maxReached = true
      
        $('#photo_choices ul').css('background-image', 'none')
        @state.pendingRequest = false
  
  showAlbumPhotos: (e) ->
    console.log('albums')
  
  reset: (e) ->
    $('#select_from_container')
      .find('div').removeClass('selected').end()
      .find('a').show().end()
      .find('select').hide().find('option:first').attr('selected', 'selected')
    $('#photo_choices')
      .hide()
      .find('ul').css('background', 'transparent url(/web/img/spinner.gif) no-repeat center center')
      .find('li').remove()
    @state = _.extend(@state, {page: 1, maxReached: false, pendingRequest: false})
      
memoriesShowPhotosTemplate = require('templates/memories/memories_show_photos')

class exports.MemoriesShowPhotosView extends Backbone.View
  id: 'memories_show_photos_view'
  
  events:
    # Photo gallery
    'click a#show_photos': 'showPhotos'
    'click a.add_photos': 'showPhotoSelector'
    'click a.fb_gallery': 'showGallery'
    'click a.fb_gallery label': 'removePhoto'
    
    # Photo selector
    'click #select_from_container a': 'selectSource'
    'click #select_from_albums': 'showAlbums'
    'click #select_from_tagged': 'showTaggedPhotos'
    'change select': 'showAlbumPhotos'
    'click li[data-id]': 'selectPhoto'
  
  initialize: ->
    _.bindAll @, 'render'
    @model.bind 'change', @render

  render: ->
    $el = $(@el)
    $(@el).html memoriesShowPhotosTemplate {model: @model}
    @  
  
  # PHOTO GALLERY
  
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
    $(e.currentTarget).attr('data-stepped', 'true')
    $add = $('#add_photos')
    $ps = $('#photo_selector_view')
    if $ps.is(':visible')
      $add.text('Add Photos')
      $ps.fadeOut()
    else
      @views.photoSelector.reset()
      $add.text('Close')
      $ps.fadeIn()

  showGallery: (e) ->
    e.preventDefault()
    $pic = $(e.target)
    $pic.fbGallery() if $pic.filter('a').length # Do not open the gallery if the close button was clicked

  removePhoto: (e) ->
    $el = $(e.currentTarget)
    $photo = $el.parent()

    # Update the model
    photos = @model.get 'photos'
    photos = _.reject photos, (p) -> p.photo == $photo.attr 'data-photo'
    @model.set {photos}

    # Removing main photo
    if $el.parents('#photo').length

      $el.parent()
        .removeClass('fb_gallery')
        .addClass('add_photos')
        .css({backgroundImage: 'url(/timeline/_design/timeline/web/img/add_photo.png)', height: 160})
        .attr('href', '#')

    # Removing photo from the gallery
    else

      # Remove the thumbnail
      $el.parents('li')
        .css('background', 'rgb(242, 242, 242)')
        .html('')

      # Remove any entirely blank rows
      squares = Math.ceil($('#photos a.fb_gallery').length / 5) * 5 - 1
      $('#photos ul li:gt('+squares+')').remove()

      # Shift photos left if one from the middle of the grid is removed
      $photos = $('#photos a.fb_gallery')
      $photos.each (i) ->
        $this = $(@)
        $priorPhotoContainer = $this.parent().prev().filter('li')
        if $priorPhotoContainer.length and not $priorPhotoContainer.find('a').length
          bg = $this.parent().css('background-image')
          $this.parent().css('background', 'rgb(242, 242, 242)')
          $priorPhotoContainer
            .css('background-image', bg)
            .append($this)

      # No need for a hide photos link when there is only a single row in the grid
      $('a#show_photos').text('') if $photos.length <= 5

      # Put the add photos icon back in the fifth square, if it no longer has a thumbnail in it
      $fifthSquare = $('#photos ul li:nth-child(5)')
      if not $fifthSquare.find('a.fb_gallery').length
        $fifthSquare.html('<a href="/web/img/add_photo.png" class="add_photos"></a>')
  
  # PHOTO SELECTOR
  
  selectSource: (e) ->
    e.preventDefault()
    $el = $(e.currentTarget)
    if not $el.hasClass('selected')
      @reset()
      $el.parent().addClass('selected')
  
  showAlbums: (e) ->
    e.preventDefault()
    
    $el = $(@el)
    $el.find('option:gt(0)').remove()
    for album in USER.ALBUMS.data
      $el.find('select').append($('<option value="'+album.id+'">'+album.name+'&nbsp;</option>'))
    
    $(e.currentTarget).hide().siblings().show()
    $.centerCheat()
          
  showTaggedPhotos: (e) ->
    $('#photo_choices')
      .show()
      .find('ul')
        # Backbone scroll listener not working ???
        .unbind()
        .scroll (e) =>
          @infinityScroll(e, '/me/photos')
          @
        .trigger('scroll')

  state:
    limit: 60
    page: 1
    maxReached: false
    pendingRequest: false

  infinityScroll: (e, url) ->
    $el = $(e.currentTarget)
    if (@state.page == 1 or 700 >= Math.ceil($el.find('li').length / 3) * 140 - $el.scrollTop()) and not @state.pendingRequest and not @state.maxReached
      
      @state.pendingRequest = true
      FB.api url, {limit: @state.limit, offset: (@state.page - 1) * @state.limit}, (response) =>
        
        for photos in response.data
          p = {}
          for photo in photos.images
            p.xlarge = photo if photo.width <= 720 and not p.xlarge
            p.large = photo if photo.width <= 720 and not p.large
            p.medium = photo if photo.width <= 180 and not p.medium
            p.small = photo if photo.width <= 130 and not p.small
          $photo = $('<li></li>')
            .attr('data-id', photos.id)
            .attr('data-small', p.small.source)
            .attr('data-medium', p.medium.source)
            .attr('data-large', p.large.source)
            .attr('data-xlarge', p.xlarge.source)
            .css('background', '#000 url('+p.medium.source+') no-repeat center center')
          $('#photo_choices ul').append($photo)
      
        $('#photo_choices ul li:nth-child(3n+2)').addClass('middle')
      
        if response.paging && response.paging.next
          @state.page++
        else
          @state.maxReached = true
      
        $('#photo_choices ul').css('background-image', 'none')
        @state.pendingRequest = false
  
  showAlbumPhotos: (e) ->
    @reset(partial=true)
    url = $(e.currentTarget).val()+'/photos'
    if url.length > 7
      $('#photo_choices')
        .show()
        .find('ul')
          .unbind()
          .scroll (e) =>
            @infinityScroll(e, url)
            @
          .trigger('scroll')
  
  selectPhoto: (e) ->
    $el = $(e.currentTarget)
    $photo = $('#photo a.add_photos')
    $photos = $('#photos li')
    
    if not $('a[href="'+$el.attr('data-xlarge')+'"]').length
    
      if $photo.length
        # There is no main photo for the memory, so add it
        image = new Image()
        image.onload = ->
          $photo
            .removeClass('add_photos')
            .addClass('fb_gallery')
            .css({backgroundImage: 'url('+$el.attr('data-medium')+')', height: image.height})
            .attr('href', $el.attr('data-xlarge'))
        image.src = $el.attr('data-medium')
    
      else
        # This photo is not already in the gallery, so add it
        background = "#000 url(#{$el.attr 'data-small'}) no-repeat center center"
        $link = $("<a href=\"#{$el.attr 'data-xlarge'}\" data-photo=\"#{$el.attr 'data-id'}\" class=\"fb_gallery\"><label></label></a>")
    
        if $photos.find('a.fb_gallery').length < $photos.length
          # Replace placeholder with a thumbnail
          $photos.each ->
            $this = $(this)
            if not $this.find('a.fb_gallery').length
              $this
                .find('a').remove().end()
                .css('background', background)
                .append($link)
              return false
        else
          # Thumbnail in a new row
          $newPhoto = $('<li></li>')
            .css('background', background)
            .append($link)
          $('#photos ul')
            .append($newPhoto)
            .append($('<li></li><li></li><li></li><li></li>'))
    
        # Ensure all thumbnails in the gallery are displayed
        $('#photos li').fadeIn ->
          $('#show_photos').text('Hide Photos') if $('#photos li a.fb_gallery').length > 5
    
      # A photo was added, so the model must be updated
      photos = @model.get 'photos'
      photos.push
        photo: $el.attr 'data-id'
        addedBy: USER.ME.id
      @model.set {photos}
  
  reset: (partial=false)->
    # Resets the widget in its entirety
    if not partial
      $('#select_from_container')
        .find('div').removeClass('selected').end()
        .find('a').show().end()
        .find('select').hide().find('option:first').attr('selected', 'selected')
    # Resets the actual display of photos
    $('#photo_choices')
      .hide()
      .find('ul').css('background', 'transparent url(/timeline/_design/timeline/web/img/spinner.gif) no-repeat center center')
      .find('li').remove()
    @state = _.extend(@state, {page: 1, maxReached: false, pendingRequest: false})
      
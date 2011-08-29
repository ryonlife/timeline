memoriesShowPhotosTemplate = require('templates/memories/memories_show_photos')

class exports.MemoriesShowPhotosView extends Backbone.View
  id: 'memories_show_photos_view'
  
  events:
    # Photo gallery
    'click a#show_full_grid': 'showPhotos'
    'click a#hide_full_grid': 'hidePhotos'
    'click a.fb_gallery': 'showGallery'
    'click a.fb_gallery label': 'removePhoto'
    
    # Photo selector
    'click a.add_photos': 'showPhotoSelector'
    'click a#hide_photo_selector': 'hidePhotoSelector'
    'click #select_from_container a': 'selectPhotoSelectorSource'
    'click #select_from_tagged': 'showPhotoSelectorPhotos'
    'change select#albums': 'showPhotoSelectorPhotos'
    'click li[data-id]': 'selectPhoto'
    
  uiStates:
    fullGrid: false
    photoSelector: false
    photoSelectorSource: null
    photoSelectorAlbum: null
    photoSelectorChoices: false
    infinityScroller:
      limit: 60
      page: 1
      maxReached: false
      pendingRequest: false
  
  initialize: ->
    _.bindAll @, 'render'
    @model.bind 'change', @render

  render: ->
    $el = $(@el)
    $(@el).html memoriesShowPhotosTemplate {model: @model, uiStates: @uiStates}
    @
  
  # PHOTO GALLERY
  
  showPhotos: (e) ->
    e.preventDefault()
    @uiStates.fullGrid = true
    @render()
    
  hidePhotos: (e) ->
    e.preventDefault()
    @uiStates.fullGrid = false
    @render()

  showGallery: (e) ->
    e.preventDefault()
    $el = $(e.currentTarget)
    $el.fbGallery() if $el.filter('a').length # Do not open the gallery if the close button was clicked

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
  
  showPhotoSelector: (e) ->
    e.preventDefault()
    @uiStates.photoSelector = true
    @render()
    
  hidePhotoSelector: (e) ->
    e.preventDefault()
    @uiStates.photoSelector = false
    @render()
    
  selectPhotoSelectorSource: (e) ->
    e.preventDefault()
    @uiStates.photoSelectorSource = $(e.currentTarget).attr 'data-source'
    @uiStates.photoSelectorChoices = false 
    @render()
    $.centerCheat()
          
  showPhotoSelectorPhotos: (e) ->
    e.preventDefault()
    $el = $(e.currentTarget)
    @uiStates.photoSelectorAlbum = if $el.is 'select' then $el.val() else null
    @uiStates.photoSelectorChoices = if @uiStates.photoSelectorSource == 'albums' and not @uiStates.photoSelectorAlbum then false else true
    @render()
    $.centerCheat()
    if @uiStates.photoSelectorSource == 'tags' or @uiStates.photoSelectorAlbum
      @uiStates.infinityScroller = _.extend @uiStates.infinityScroller, {page: 1, maxReached: false, pendingRequest: false}
      # Setting a 'scroll' event handler in MemoriesShowPhotosView.events is not binding correctly, so doing it here, and also triggering it
      $('#photo_choices ul')
        .unbind()
        .scroll (e) =>
          @infinityScroll(e)
          @
        .scroll()
    
  infinityScroll: (e) ->
    $el = $(e.currentTarget)
    
    url = if @uiStates.photoSelectorSource == 'tags' then '/me/photos' else "#{$('#albums').val()}/photos"
    usIs = @uiStates.infinityScroller
    
    if (usIs.page == 1 or 700 >= Math.ceil($el.find('li').length / 3) * 140 - $el.scrollTop()) and not usIs.pendingRequest and not usIs.maxReached
      
      @uiStates.infinityScroller.pendingRequest = true
      FB.api url, {limit: @uiStates.infinityScroller.limit, offset: (@uiStates.infinityScroller.page - 1) * @uiStates.infinityScroller.limit}, (response) =>
        
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
          @uiStates.infinityScroller.page++
        else
          @uiStates.infinityScroller.maxReached = true
      
        $('#photo_choices ul').css('background-image', 'none')
        @uiStates.infinityScroller.pendingRequest = false
  
  selectPhoto: (e) ->
    $el = $(e.currentTarget)
    @model.addPhoto $el.attr 'data-id'
    
    # @model.get 'photos'
    # photos.push
    #   photo: $el.attr 'data-id'
    #   addedBy: USER.ME.id
    # @model.set {photos}
    # 
    # 
    # $photo = $('#photo a.add_photos')
    # $photos = $('#photos li')
    # 
    # if not $('a[href="'+$el.attr('data-xlarge')+'"]').length
    # 
    #   if $photo.length
    #     # There is no main photo for the memory, so add it
    #     image = new Image()
    #     image.onload = ->
    #       $photo
    #         .removeClass('add_photos')
    #         .addClass('fb_gallery')
    #         .css({backgroundImage: 'url('+$el.attr('data-medium')+')', height: image.height})
    #         .attr('href', $el.attr('data-xlarge'))
    #     image.src = $el.attr('data-medium')
    # 
    #   else
    #     # This photo is not already in the gallery, so add it
    #     background = "#000 url(#{$el.attr 'data-small'}) no-repeat center center"
    #     $link = $("<a href=\"#{$el.attr 'data-xlarge'}\" data-photo=\"#{$el.attr 'data-id'}\" class=\"fb_gallery\"><label></label></a>")
    # 
    #     if $photos.find('a.fb_gallery').length < $photos.length
    #       # Replace placeholder with a thumbnail
    #       $photos.each ->
    #         $this = $(this)
    #         if not $this.find('a.fb_gallery').length
    #           $this
    #             .find('a').remove().end()
    #             .css('background', background)
    #             .append($link)
    #           return false
    #     else
    #       # Thumbnail in a new row
    #       $newPhoto = $('<li></li>')
    #         .css('background', background)
    #         .append($link)
    #       $('#photos ul')
    #         .append($newPhoto)
    #         .append($('<li></li><li></li><li></li><li></li>'))
    # 
    #     # Ensure all thumbnails in the gallery are displayed
    #     $('#photos li').fadeIn ->
    #       $('#show_photos').text('Hide Photos') if $('#photos li a.fb_gallery').length > 5
    # 
    #   # A photo was added, so the model must be updated
    #   photos = @model.get 'photos'
    #   photos.push
    #     photo: $el.attr 'data-id'
    #     addedBy: USER.ME.id
    #   @model.set {photos}
  
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
    @uiStates.infinityScroller = _.extend(@uiStates.infinityScroller, {page: 1, maxReached: false, pendingRequest: false})
      
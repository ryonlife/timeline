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
    
  resetUiStates: (override={}) ->
    @uiStates =
      fullGrid: false
      photoSelector: false
      photoSelectorSource: null
      photoSelectorAlbum: null
      photoSelectorChoices: false
      photos: []
      infinityScroller:
        limit: 60
        page: 1
        maxReached: false
        pendingRequest: false
    _.extend @uiStates, override
  
  initialize: ->
    @resetUiStates()
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
    if @uiStates.photoSelector is false
      @uiStates.photoSelector = true
      @render()

  hidePhotoSelector: (e) ->
    e.preventDefault()
    @resetUiStates {fullGrid: @uiSstates.fullGrid}
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
          
          @uiStates.photos.push
            id: photos.id
            small: p.small.source
            medium: p.medium.source
            large: p.large.source
            xlarge: p.xlarge.source
      
        if response.paging && response.paging.next
          @uiStates.infinityScroller.page++
        else
          @uiStates.infinityScroller.maxReached = true
      
        $('#photo_choices ul').css('background-image', 'none')
        @uiStates.infinityScroller.pendingRequest = false
  
  selectPhoto: (e) ->
    $el = $(e.currentTarget)
    @model.addPhoto
      id: $el.attr 'data-id'
      small: $el.attr 'data-small'
      medium: $el.attr 'data-medium'
      xlarge: $el.attr 'data-xlarge'
    @model.save()
    
MemoriesShowHeaderView = require('views/memories/memories_show_header_view').MemoriesShowHeaderView
MemoriesShowPhotoSelectorView = require('views/memories/memories_show_photo_selector_view').MemoriesShowPhotoSelectorView

memoriesShowTemplate = require('templates/memories/memories_show')
memoriesShowProfilePicTemplate = require('templates/memories/memories_show_profile_pic')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show_view'
  
  events:
    'click a#tag_friends': 'showFriendSelector'
    'friendSelection a#tag_friends': 'updateFriendSelections'
    'click a#self_tag': 'selfTag'
    'click li .profile_pic label': 'removeTag'
    
    'click a#show_photos': 'showPhotos'
    'click a.add_photos': 'showPhotoSelector'
    'click a.fb_gallery': 'showGallery'
    'click a.fb_gallery label': 'removePhoto'
  
  initialize: ->
    @model.fetch() if not @model.isNew()
    @views = {}
  
  render: ->
    $el = $(@el)
    
    # Container
    $el.html memoriesShowTemplate {model: @model}
    
    # Header
    memoriesShowHeaderView = new MemoriesShowHeaderView {model: @model}
    $el.find('#header').html memoriesShowHeaderView.render().el
    
    # # Sidebar
    # memoriesShowFriendsView = new MemoriesShowFriendsView {model: @model}
    # $el.find('#sidebar').html memoriesShowFriendsView.render().el
    
    # Photo selector
    @views.photoSelector = new MemoriesShowPhotoSelectorView
    @views.photoSelector.model = @model
    $el.find('#photos').after @views.photoSelector.render().el
    
    # Done!!
    @
  
  showFriendSelector: (e) ->
    e.preventDefault()
    
    selectedFriends = []
    $('#friends .name [uid]').each -> selectedFriends.push $(this).attr('uid')
    
    $(e.currentTarget)
      .attr('data-stepped', 'true')
      .fbFriendSelector(USER.FRIENDS.data, selectedFriends)
  
  updateFriendSelections: (e, newFriends) ->
    $el = $(e.currentTarget)
    $friends = $('ul#friends')
    
    # Friends before the update
    fbIds = []
    $friends.find('[data-fb-id]').each -> fbIds.push($(@).attr('data-fb-id'))
    
    # Insert new friends into the list and model
    for friend in newFriends
      if friend.id not in fbIds
        profilePic = memoriesShowProfilePicTemplate {friend: friend, taggedBy: USER.ME.id}
        $friends.find('li.tag_button_container').after(profilePic)
    FB.XFBML.parse document.getElementById('friends')
    
    # Users own pic should always be first
    $('.tag_button_container').after($friends.find("li[data-fb-id=#{USER.ME.id}]"))
    
    @updateFriends()
      
  selfTag: (e) ->
    e.preventDefault()
    $(e.currentTarget).hide()
    $('a#tag_friends')
      .removeClass('hide')
      .trigger('friendSelection', [[{id: USER.ME.id, name: USER.ME.name, link: USER.ME.link}]])
  
  removeTag: (e) ->
    $(e.currentTarget).parents('li').remove()
    @updateFriends()
  
  updateFriends: ->
    $friends = $('ul#friends')
    $button = $('a#tag_friends')
    
    # Create an array of friends/taggers
    friends = []
    $friends.find('[data-fb-id]').each ->
      $this = $(@)
      friends.push
        tagged: $this.attr('data-fb-id')
        taggedBy: $this.attr('data-tagged-by')
    
    # Update the model
    @model.set {friends: friends}
    
    # Update the friend count
    friendsPresent =
      if not friends.length
        'Nobody was there.'
      else if friends.length == 1
        '1 person was there.'
      else
        friends.length+' people were there.'
    $friends.find('.count').text(friendsPresent)
    
    # Update the tag friends button
    $button
      .html('<span class="tag"></span> Tag Friends')
      .css({'width': 'auto', 'display': 'inline-block'})
    $button.css({'width': $button.width(), 'display': 'block'})
    
    # Show the self tagging button if the user removed himself
    if not $friends.find("li[data-fb-id=#{USER.ME.id}]").length
      $button.hide()
      $('a#self_tag').show()
  
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
      
memoriesShowTemplate = require('templates/memories/memories_show')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show'
  
  events:
    'click a#tag_friends': 'showFriendSelector'
    'friendSelection a#tag_friends': 'updateFriendSelections'
    
    'click a#self_tag': 'selfTag'
    'click li .profile_pic label': 'removeTag'
    
    'click a#show_photos': 'showPhotos'
    'click a.add_photos': 'showPhotoSelector'
    'click a.fb_gallery': 'showGallery'
    'click a.fb_gallery label': 'removePhoto'
    
    'mouseover .editable': 'showIndicator'
    'mouseout .editable': 'hideIndicator'
    
    'mouseover .indicator': 'markHovered'
    'mouseout .indicator': 'markNotHovered'
    'click .indicator': 'triggerEdit'
    'click .editable': 'showEdit'
    'keyup .edit_field': 'saveEdit'
  
  render: ->
    $view = $(@el).html memoriesShowTemplate()
    $view.find('#photos').after app.views.memories_show_photo_selector.render().el
    @
    
  showFriendSelector: (e) ->
    e.preventDefault()
    
    selectedFriends = []
    $('#friends .name [uid]').each -> selectedFriends.push $(this).attr('uid')
    $(e.currentTarget).fbFriendSelector(USER.FRIENDS.data, selectedFriends)
  
  updateFriendSelections: (e, newFriendIds) ->
    $el = $(e.currentTarget)
    $friends = $('ul#friends')
    
    # Friends before the update
    preFbIds = []
    $friends.find('[data-fb-id]').each -> preFbIds.push($(@).attr('data-fb-id'))
    
    # Insert new friends into the list
    for friendId in newFriendIds
      if friendId not in preFbIds
        picAndName = "
          <li data-fb-id=\"#{friendId}\">
            <div class=\"profile_pic\">
              <label></label>
              <fb:profile-pic class=\"image\" facebook-logo=\"false\" linked=\"false\" size=\"square\" uid=\"#{friendId}\" />
            </div>
            <div class=\"name\" >
              <fb:name uid=\"#{friendId}\" useyou=\"false\" />
            </div>
          </li>
        "
        $friends.find('li.tag_button_container').after(picAndName)
    FB.XFBML.parse document.getElementById('friends')
    
    # Users own pic should always be first
    $('.tag_button_container').after($friends.find("li[data-fb-id=#{USER.ME.id}]"))
    
    @updateFriendCount()
  
  selfTag: (e) ->
    e.preventDefault()
    $(e.currentTarget).hide()
    $('a#tag_friends').removeClass('hide').trigger('friendSelection', [[USER.ME.id]])
  
  removeTag: (e) ->
    $(e.currentTarget).parents('li').remove()
    @updateFriendCount()
  
  updateFriendCount: ->
    $friends = $('ul#friends')
    $button = $('a#tag_friends')
    
    # Friends after the update
    postFbIds = []
    $friends.find('[data-fb-id]').each -> postFbIds.push($(@).attr('data-fb-id'))
    
    # Update the friend count
    friendsPresent =
      if not postFbIds.length
        'nobody was there'
      else if postFbIds.length == 1
        '1 person was there'
      else
        postFbIds.length+' people were there'
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
    $el = $(e.currentTarget)
    
    # Removing main photo
    if $el.parents('#photo').length
      
      $el.parent()
        .removeClass('fb_gallery')
        .addClass('add_photos')
        .css({backgroundImage: 'url(/web/img/add_photo.png)', height: 120})
        .attr('href', '#')
    
    # Removing photo from the gallery
    else
      
      # Remove the thumbnail
      $el.parents('li')
        .css('background', '#ECEFF5')
        .html('')
      
      # Put the add photos icon back in the fifth square, if it no longer has a thumbnail in it
      $fifthSquare = $('#photos ul li:nth-child(5)')
      if not $fifthSquare.find('a.fb_gallery').length
        $fifthSquare.html('<a href="/web/img/add_photo.png" class="add_photos"></a>')
        
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
          $this.parent().css('background', '#ECEFF5')
          $priorPhotoContainer
            .css('background-image', bg)
            .append($this)

      # No need for a hide photos link when there is only a single row in the grid
      $('a#show_photos').text('') if $photos.length <= 5
    
  showIndicator: (e) ->
    if not $('.edit_field:visible').length
    
      clearTimeout(@timeout)
    
      $el = $(e.currentTarget)
      $view = $(@el)
      $indicator = $('.indicator')
    
      if $el.is('#description')
        left = $el.offset().left - 3
        top = $el.offset().top + $el.height() + 2
      else
        left = $el.offset().left + $el.width()
        top =
          if $el.height() >= 18
            $el.offset().top + ($el.height() - 18) / 2
          else
            $el.offset().top - (18 - $el.height()) / 2
    
      $indicator
        .show()
        .css({left, top})
        .data('target', e.currentTarget)
    
  hideIndicator: (e) ->
    @timeout = setTimeout ->
      $indicator = $('.indicator')
      $indicator.hide() if not $indicator.data('hovered')
    , 250
    
  markHovered: (e) ->
    $(e.currentTarget).data('hovered', true)
    
  markNotHovered: (e) ->
    $(e.currentTarget).data('hovered', false).hide()
    
  triggerEdit: (e) ->
    e.preventDefault()
    $el = $(e.currentTarget).data('hovered', false).hide()
    $($el.data('target')).trigger('click')
    
  showEdit: (e) ->
    if not $('.edit_field:visible').length
      $el = $(e.currentTarget)
      $el.hide()
    
      $('.indicator').trigger('mouseout')
    
      $field = $el.next()
      $field
        .show()
        .val($el.text())
    
  saveEdit: (e) ->
    if e.keyCode == 13
      $el = $(e.currentTarget).hide()
      $target = $("##{$el.attr('id').substr(5)}").text($el.val()).show()
    
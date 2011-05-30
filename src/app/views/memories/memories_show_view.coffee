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
    $el = $(@el).html memoriesShowTemplate()
    $el.find('#photos').after app.views.memories_show_photo_selector.render().el
    @
  
  tutorial: ->
    steps = [
      {target: $('[data-step=1]'), title: 'Getting Started', content: '<p>This is a blank canvas for recording a memory.</p><p>As your collection of memories builds, there are cool ways to visualize it, like timelines and calendars.</p><p class="tar"><a href="#" class="gs" id="next">Click here to get started &raquo;</a></p>', my: 'top left', at: 'bottom left'}
      {target: $('[data-step=1]'), title: 'Step 1: Title', content: '<p>Your memory needs a title.</p><p>Click <strong class="mirror"></strong> to edit the title, then press the <strong>return/enter</strong> key when you\'re done.</p>', my: 'top left', at: 'bottom left'}
      {target: $('[data-step=2]'), title: 'Step 2: Date', content: '<p>When did it happen?</p><p>Click <strong class="mirror"></strong>, then use the calendar to select the date when your memory took place.</p>', my: 'top left', at: 'bottom left'}
      {target: $('[data-step=3]'), title: 'Step 3: Friends', content: '<p>Who was there?</p><p>Click the <strong>Tag Friends</strong> button to select the friends who were with you to experience this memory.</p>', my: 'top left', at: 'bottom left'}
      {target: $('[data-step=4]'), title: 'Step 4: Description', content: '<p>Your memory needs a description.</p><p>Click the <strong class="mirror"></strong> text to edit the description, then press the <strong>return/enter</strong> key when you\'re done.</p>', my: 'top left', at: 'bottom left'}
      {target: $('[data-step=5]'), title: 'Step 5: Photos', content: '<p>Your memory needs photos.</p><p>Click the <strong>Add Photos</strong> link to browse and select from your Facebook photos.</p>', my: 'top right', at: 'bottom right'}

    ]
    _.each steps, (step, i) ->
      if i
        if i == 1
          steps[i].content += "<p class=\"clearfix tar\"><a href=\"#\" id=\"next\">Step #{i+1} &raquo;</a></p>"
        else if i == steps.length - 1
          steps[i].content += "<p class=\"clearfix tar\"><a href=\"#\" id=\"prev\">&laquo; Step #{i-1}</a></p>"
        else
          steps[i].content += "<p class=\"clearfix tar\"><a href=\"#\" id=\"prev\">&laquo; Step #{i-1}</a>&nbsp;|&nbsp;<a href=\"#\" id=\"next\" class=\"fr\">Step #{i+1} &raquo;</a></p>"
    
    $(@el).qtip
      id: 'tutorial'
      content:
        text: steps[0].content
        title:
          text: steps[0].title
          button: true
      position:
        my: 'top left'
        at: 'bottom left'
        target: steps[0].target
      style:
        classes: 'ui-tooltip-shadow ui-tooltip-default'
      show:
        event: false
        ready: true
      hide: false
      events:
        render: (e, api) ->
          $tooltip = api.elements.tooltip
          api.step = 0
          $tooltip.bind 'next prev', (e) ->
            # Get the settings and content for the current step
            api.step += if e.type is 'next' then 1 else -1
            api.step = Math.min(steps.length - 1, Math.max(0, api.step))
            current = steps[api.step]
            # Tweak content and settings based for the current step
            if current
              api.set 'content.text', current.content
              api.set 'content.title.text', current.title
              api.set 'position.target', current.target
              api.set 'position.my', current.my
              api.set 'position.at', current.at
            text = $(current.target).text()
            match = text.match /^(\w+\b.*?){3}/
            if match
              text = if match[0].length < text.length then match[0]+'...' else match[0]
            $tooltip.find('.mirror').text(text)
              
    $('#next, #prev').live 'click', (e) ->
      e.preventDefault()
      $('#ui-tooltip-tutorial').triggerHandler @id
  
  datepickers: ->
    $.extend($.datepicker.__proto__, {
      _updateAlternate: (inst) ->
        altField = this._get(inst, 'altField')
        if altField
          altFormat = this._get(inst, 'altFormat') || this._get(inst, 'dateFormat')
          date = this._getDate(inst)
          dateStr = this.formatDate(altFormat, date, this._getFormatConfig(inst))
          $(altField).each -> $(this).text(dateStr)
    })
    
    $view = $(@el)
    # Initialize the jQuery UI datepickers
    $view.find('.datepicker').each ->
      $this = $(@)
      birthdayParts = '11/27/1982'.split('/')
      options =
        showOn: 'both'
        changeMonth: true
        changeYear: true
        dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        showAnim: ''
        altFormat: 'MM d, yy'
        altField: '#'+$(this).attr('id').slice(0, -6)
        maxDate: 0
        minDate: new Date(birthdayParts[2], birthdayParts[0] - 1, birthdayParts[1])
        yearRange: birthdayParts[2].toString()+':-nn:+nn'
      # Should I want to go back to allowing a memory to have a date range, this ensures the second date cannot take place before the first
      # if $this.is(':first-of-type')
      #   restrictRange = (dateText, datepicker) ->
      #     $this = $(@)
      #     date = $this.datepicker('getDate')
      #     $endDatepicker = $view.find('.datepicker').last()
      #     $endDatepicker.datepicker('option', 'minDate', date)
      #     $endDatepicker.datepicker('option', 'yearRange', date.getFullYear().toString()+':-nn+nn')
      #   options = _.extend options, {onSelect: restrictRange, onChangeMonthYear: restrictRange}        
      options = _.extend options, {onSelect: (dateText, datepicker) -> $(@).hide().prev().show()}
      $this.datepicker options
  
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
    if not $('.edit_field:visible').length and not $('#start_datepicker:visible').length and not $('#ui-tooltip-tutorial:visible').length
    
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
    if not $('.edit_field:visible').length and not $('#start_datepicker:visible').length
      $el = $(e.currentTarget)
      $el.hide()
    
      $('.indicator').trigger('mouseout')
    
      $field = $el.next()
      $field
        .show()
        .val($el.text())
        .select()
      
      $('#memories_show').qtip('hide')
    
  saveEdit: (e) ->
    if e.keyCode == 13
      $el = $(e.currentTarget).hide()
      $target = $("##{$el.attr('id').substr(5)}").text($el.val()).show()
    
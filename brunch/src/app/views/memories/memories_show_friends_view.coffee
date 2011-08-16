memoriesShowFriendsTemplate = require('templates/memories/memories_show_friends')

class exports.MemoriesShowFriendsView extends Backbone.View
  id: 'memories_show_friends_view'
  
  events:
    'click a#tag_friends': 'showFriendSelector'
    'friendSelection a#tag_friends': 'updateFriendSelections'
    'click a#self_tag': 'selfTag'
    'click li .profile_pic label': 'removeTag'
  
  initialize: ->
    _.bindAll @, 'render'
    @model.bind 'change', @render
  
  render: ->
    $el = $(@el)
    $el.html memoriesShowFriendsTemplate {model: @model}
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
        
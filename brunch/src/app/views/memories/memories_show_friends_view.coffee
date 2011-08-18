memoriesShowFriendsTemplate = require('templates/memories/memories_show_friends')

class exports.MemoriesShowFriendsView extends Backbone.View
  id: 'memories_show_friends_view'
  
  events:
    'click a#tag_friends': 'showFriendSelector'
    'friendSelection a#tag_friends': 'updateFriendSelections'
    'click a#self_tag': 'selfTag'
    'click li .profile_pic label': 'untag'
  
  initialize: ->
    _.bindAll @, 'render'
    @model.bind 'change', @render
  
  render: ->
    $el = $(@el)
    $el.html memoriesShowFriendsTemplate {model: @model}
    @
    
  showFriendSelector: (e) ->
    e.preventDefault()
    $(e.currentTarget).fbFriendSelector USER.FRIENDS.data, @model.taggedFriendIds()

  updateFriendSelections: (e, newFriends) ->
    for friend in newFriends
      @model.tagFriend
        tagged: friend.id
        taggedName: friend.name
    @model.save()

  selfTag: (e) ->
    e.preventDefault()
    @updateFriendSelections e, [{id: USER.ME.id, name: "#{USER.ME.first_name} #{USER.ME.last_name}"}]

  untag: (e) ->
    e.preventDefault()
    $picContainer = $(e.currentTarget).parents('li')
    @model.untagFriend $picContainer.attr('data-fb-id')
    @model.save()
    
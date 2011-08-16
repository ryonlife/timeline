class exports.Memory extends Backbone.Model
  
  urlRoot: '/memories'
  
  defaults:
    owner: null
    favoriteOf: []
    title: 'New Memory Title'
    date: $.datepicker.formatDate('yy-mm-dd', new Date())
    description: 'Describe your memory and what makes it worth remembering...'
    friends: []
    photos: []
  
  initialize: ->
    @set
      owner: USER.ME.id
      favoriteOf: [USER.ME.id]
      friends: [{tagged: USER.ME.id, taggedName: "#{USER.ME.first_name} #{USER.ME.last_name}", taggedBy: USER.ME.id}]
  
  formatDate: ->
    $.datepicker.formatDate 'MM d, yy', new Date @get 'date'
    
  addFavoriteOf: (fbId) ->
    @set {favoriteOf: _.union @get('favoriteOf'), [userId]}
  
  tagFriend: (friend) ->
    taggedFriendIds = @taggedFriendIds()
    if not _.include taggedFriendIds, friend.tagged
      friends = @get 'friends'
      friend.taggedBy = USER.ME.id
      friends.push friend
      @set {friends}
  
  untagFriend: (friendId) ->
    if friendId != @get 'owner' and _.include friendId in @taggedFriendIds()
      friends = @get 'friends'
      friendsToKeep = _.select friends, (friend) -> friend.tagged != friendId
      friendToUntag = _.detect friends, (friend) -> friend.tagged == friendId
      @set {friends: friendsToKeep} if _.include [friendId, friendToUntag.taggedBy, @get('owner')], USER.ME.id
  
  taggedFriendIds: ->
    _.map @get('friends'), (friend) -> friend.tagged
  
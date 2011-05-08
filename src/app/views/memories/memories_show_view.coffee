memoriesShowTemplate = require('templates/memories/memories_show')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show'
  
  events:
    'click #tag_friends' : 'showFriendSelector'
  
  render: ->
    $view = $(@.el).html(memoriesShowTemplate())
    
    # Show the number of tagged friends on the Tag Friends buttons
    friends = [{'id': 1, 'name': 'Ryan McKillen'}]
    $view.find('#tag_friends').html('<span class="tag"></span> Tag Friends ('+parseInt(friends.length)+')') if friends.length
    
    @
    
  showFriendSelector: (e) ->
    e.preventDefault()
    
    # $.friendSelector([{'id': 1, 'name': 'Ryan McKillen'}])
    $('<div id="friend_selector"></div>').friendSelector([{'id': 1, 'name': 'Ryan McKillen'}]).dialog('Tag Friends')
    
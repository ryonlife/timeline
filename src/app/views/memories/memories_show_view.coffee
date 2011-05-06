memoriesShowTemplate = require('templates/memories/memories_show')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show'
  
  events:
    'click #tag_friends' : 'showFriendSelector'
  
  render: ->
    $view = $(@.el).html(memoriesShowTemplate())    
    @
    
  showFriendSelector: (e) ->
    e.preventDefault()
    $('<div id="friend_selector"></div>')
      .friendSelector($(e.currentTarget), $('#friends'), [{'id': 1, 'name': 'Ryan McKillen'}])
      .dialog('Tag Friends')
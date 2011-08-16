MemoriesShowHeaderView = require('views/memories/memories_show_header_view').MemoriesShowHeaderView
MemoriesShowFriendsView = require('views/memories/memories_show_friends_view').MemoriesShowFriendsView
MemoriesShowPhotosView = require('views/memories/memories_show_photos_view').MemoriesShowPhotosView

memoriesShowTemplate = require('templates/memories/memories_show')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show_view'
  
  initialize: ->
    @model.fetch() if not @model.isNew()
  
  render: ->
    $el = $(@el)
    
    # Container
    $el.html memoriesShowTemplate {model: @model}
    
    # Header
    memoriesShowHeaderView = new MemoriesShowHeaderView {model: @model}
    $el.find('#header').html memoriesShowHeaderView.render().el
    
    # Sidebar
    memoriesShowFriendsView = new MemoriesShowFriendsView {model: @model}
    $el.find('#sidebar').html memoriesShowFriendsView.render().el
    
    # Photos
    memoriesShowPhotosView = new MemoriesShowPhotosView {model: @model}
    $el.find('#content').prepend memoriesShowPhotosView.render().el
    
    # Done!!
    @
          
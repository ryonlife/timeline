memoriesIndexTemplate = require('templates/memories/memories_index')

class exports.MemoriesIndexView extends Backbone.View
  id: 'memories_index_view'
  
  initialize: ->
    _.bindAll @, 'render'
    # app.collections.memories.bind 'add', @render
    # app.collections.memories.bind 'refresh', @render
  
  render: ->
    $(@el).html memoriesIndexTemplate()
    @
    
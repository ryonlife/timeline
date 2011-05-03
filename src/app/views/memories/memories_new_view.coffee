memoriesNewTemplate = require('templates/memories/memories_new')

class exports.MemoriesNewView extends Backbone.View
  id: 'memories_new'

  render: ->
    $(@.el).html memoriesNewTemplate()
    @

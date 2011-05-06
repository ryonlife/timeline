memoriesShowTemplate = require('templates/memories/memories_show')

class exports.MemoriesShowView extends Backbone.View
  id: 'memories_show'
  
  render: ->
    $view = $(@.el).html(memoriesShowTemplate())    
    @
    
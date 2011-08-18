memoriesIndexTemplate = require('templates/memories/memories_index')

class exports.MemoriesIndexView extends Backbone.View
  id: 'memories_index_view'
  
  initialize: ->
    _.bindAll @, 'render'
    @collection.bind 'reset', @render
    @collection.fetch()
  
  render: ->
    $(@el).html memoriesIndexTemplate {collection: @collection}
    @
    
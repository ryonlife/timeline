homeTemplate = require('templates/home/home_index')

class exports.HomeIndexView extends Backbone.View
  id: 'home-view'

  render: ->
    $(@.el).html homeTemplate()
    $.get "#{CONFIG.url}/timeline/_uuids", (data) ->
      console.log data
    @

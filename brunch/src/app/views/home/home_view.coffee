homeTemplate = require('templates/home/home')

class exports.HomeView extends Backbone.View
  id: 'home-view'

  render: ->
    $(@.el).html homeTemplate()
    @

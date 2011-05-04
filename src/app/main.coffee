window.app         = {}
app.controllers    = {}
app.models         = {}
app.collections    = {}
app.views          = {}

HomeController     = require('controllers/home_controller').HomeController
HomeIndexView      = require('views/home/home_index_view').HomeIndexView

MemoriesController = require('controllers/memories_controller').MemoriesController
MemoriesNewView    = require('views/memories/memories_new_view').MemoriesNewView

$(document).ready ->
  app.initialize = ->
    app.controllers.home     = new HomeController
    app.views.home_index     = new HomeIndexView
    
    app.controllers.memories = new MemoriesController
    app.views.memories_new   = new MemoriesNewView
  
  app.initialize()
  Backbone.history.start()

require('lib/jquery.fb-dialog')
require('lib/jquery.fb-friend-selector')

window.app = {}
app.controllers = {}
app.models = {}
app.collections = {}
app.views = {}

HomeController = require('controllers/home_controller').HomeController
HomeIndexView = require('views/home/home_index_view').HomeIndexView

MemoriesController = require('controllers/memories_controller').MemoriesController
MemoriesNewView = require('views/memories/memories_new_view').MemoriesNewView
MemoriesShowView = require('views/memories/memories_show_view').MemoriesShowView

MemoriesShowPhotoSelectorView = require('views/memories/memories_show_photo_selector_view').MemoriesShowPhotoSelectorView

$(document).ready ->
  app.initialize = ->
    app.controllers.home = new HomeController
    app.views.home_index = new HomeIndexView
    
    app.controllers.memories = new MemoriesController
    app.views.memories_new = new MemoriesNewView
    app.views.memories_show = new MemoriesShowView
    
    app.views.memories_show_photo_selector = new MemoriesShowPhotoSelectorView
  
  app.initialize()
  Backbone.history.start()

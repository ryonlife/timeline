window.CONFIG = require('lib/config').config

if CONFIG.hoptoadApiKey
  $.getScript 'http://hoptoadapp.com/javascripts/notifier.js', ->
    Hoptoad.setKey(CONFIG.hoptoadApiKey)

# window.Timeline = require('lib/timeline_backbone').Timeline
# Backbone.sync = Timeline.sync

Backbone.couch_connector.config.db_name = 'timeline';
Backbone.couch_connector.config.ddoc_name = 'timeline';

window.app = {}
app.routers = {}
app.models = {}
app.collections = {}
app.views = {}

app.models.memory = require('models/memory').Memory

HomeRouter = require('routers/home_router').HomeRouter
HomeIndexView = require('views/home/home_index_view').HomeIndexView

MemoriesRouter = require('routers/memories_router').MemoriesRouter
MemoriesCollection = require('collections/memories_collection').MemoriesCollection
MemoriesShowView = require('views/memories/memories_show_view').MemoriesShowView
MemoriesShowPhotoSelectorView = require('views/memories/memories_show_photo_selector_view').MemoriesShowPhotoSelectorView

$(document).ready ->
  app.initialize = ->
    app.routers.home = new HomeRouter
    app.views.home_index = new HomeIndexView
    
    app.routers.memories = new MemoriesRouter
    app.collections.memories = new MemoriesCollection
    app.views.memories_show = new MemoriesShowView
    app.views.memories_show_photo_selector = new MemoriesShowPhotoSelectorView
  
  app.initialize()
  Backbone.history.start()

Memory = require('models/memory').Memory

MemoriesCollection = require('collections/memories_collection').MemoriesCollection

MemoriesIndexView = require('views/memories/memories_index_view').MemoriesIndexView
MemoriesShowView = require('views/memories/memories_show_view').MemoriesShowView

class exports.MemoriesRouter extends Backbone.Router
  routes:
    '!/memories': 'index'
    '!/memories/:id': 'show'
  
  index: ->
    collection = new MemoriesCollection
    view = new MemoriesIndexView {collection}
    $('#fb_wrapper').html view.render().el
  
  show: (id) ->
    model = new Memory
    model.id = id if id != 'new'
    view = new MemoriesShowView {model}
    $('#fb_wrapper').html view.render().el
    view.xfbml()
    

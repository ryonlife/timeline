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
    view = new MemoriesIndexView
    $('#fb_wrapper').html view.render().el
  
  show: ->
    id = location.hash.split('/')[2]
    
    if id == 'new'
      model = new Memory {owner: USER.ME.id}
    else
      model = new Memory
      model.id = id
    
    view = new MemoriesShowView {model}
    $('#fb_wrapper').html view.render().el
    Helpers.datepickers()
    
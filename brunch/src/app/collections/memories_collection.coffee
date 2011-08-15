Memory = require('models/memory').Memory

class exports.MemoriesCollection extends Backbone.Collection
  db:
    view: 'memories'
    changes: false
    filter: "#{Backbone.couch_connector.config.ddoc_name}/memories"
  url: '/memories'
  model: Memory
  
couchapp = require 'couchapp'
path = require 'path'

ddoc =
  _id: '_design/timeline'
  views: {}
  lists: {}
  shows: {}

module.exports = ddoc

ddoc.views.collection =
  map: (doc) ->
    emit doc.collection, doc if doc.collection

ddoc.views.memories =
  map: (doc) ->
    emit 'doc', doc if doc.collection == 'memories'

couchapp.loadAttachments ddoc, path.join(__dirname, '_attachments')

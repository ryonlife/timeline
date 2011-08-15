var couchapp = require('couchapp')
var path = require('path');

ddoc = {
  _id: '_design/timeline',
  views: {},
  lists: {},
  shows: {} 
}

module.exports = ddoc;

ddoc.views.collection = {
  map: function(doc) {
    if (doc.collection) {
      emit(doc.collection, doc);
    }
  }
}

ddoc.views.memories = {
  map: function(doc) {
    if (doc.collection == 'memories') {
      emit('doc', doc);
    }
  }
}

couchapp.loadAttachments(ddoc, path.join(__dirname, '_attachments'));

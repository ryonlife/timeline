var couchapp = require('couchapp')
var path = require('path');

ddoc = {
  _id: '_design/timeline',
  views: {},
  lists: {},
  shows: {} 
}

module.exports = ddoc;

doc.views.collection = {
  map: function(doc) {
    if (doc.collection) {
      emit(doc.collection, doc);
    }
  }
}

couchapp.loadAttachments(ddoc, path.join(__dirname, '_attachments'));

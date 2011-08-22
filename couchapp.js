(function() {
  var couchapp, ddoc, path;
  couchapp = require('couchapp');
  path = require('path');
  ddoc = {
    _id: '_design/timeline',
    views: {},
    lists: {},
    shows: {}
  };
  module.exports = ddoc;
  ddoc.views.collection = {
    map: function(doc) {
      if (doc.collection) {
        return emit(doc.collection, doc);
      }
    }
  };
  ddoc.views.memories = {
    map: function(doc) {
      if (doc.collection === 'memories') {
        return emit('doc', doc);
      }
    }
  };
  couchapp.loadAttachments(ddoc, path.join(__dirname, '_attachments'));
}).call(this);

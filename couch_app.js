var couchapp = require('couchapp')
var path = require('path');

ddoc = {
    _id: '_design/timeline',
    views: {},
    lists: {},
    shows: {} 
}

module.exports = ddoc;

couchapp.loadAttachments(ddoc, path.join(__dirname, '_attachments'));

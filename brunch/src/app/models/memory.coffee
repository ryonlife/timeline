class exports.Memory extends Backbone.Model
  
  urlRoot: '/memories'
  
  defaults:
    owner: null
    favoriteOf: []
    title: 'New Memory Title'
    date: $.datepicker.formatDate('yy-mm-dd', new Date())
    description: 'Describe your memory and what makes it worth remembering...'
    friends: []
    photos: []
  
  initialize: ->
    owner = @get 'owner'
    @set
      favoriteOf: [owner]
      friends: [{tagged: owner, taggedName: "#{USER.ME.first_name} #{USER.ME.last_name}", taggedBy: owner}]
  
  formatDate: ->
    $.datepicker.formatDate 'MM d, yy', new Date @get 'date'
    
  addFavoriteOf: (fbId) ->
    @set {favoriteOf: _.union @get('favoriteOf'), [userId]}
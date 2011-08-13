class exports.Memory extends Backbone.Model
  
  urlRoot: '/memories'
  
  defaults:
    owner: null
    favoriteOf: []
    title: null
    date: $.datepicker.formatDate('yy-mm-dd', new Date())
    description: null
    friends: []
    photos: []
  
  initialize: ->
    @set {favoriteOf: [@get('owner')]}
  
  formatDate: ->
    $.datepicker.formatDate 'MM d, yy', new Date @get 'date'
    
  addFavoriteOf: (fbId) ->
    @set {favoriteOf: _.union @get('favoriteOf'), [userId]}
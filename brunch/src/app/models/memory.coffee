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
    @attributes.favoriteOf = [@get('owner')]
  
  formatDate: ->
    $.datepicker.formatDate 'MM 2, yy', new Date @get 'date'
    
  addFavoriteOf: (fbId) ->
    # Why is this kicking an error?
    # @set 'favoriteOf', _.union(@get('favoriteOf'), [userId])
    @attributes.favoriteOf = _.union(@get('favoriteOf'), [fbId])
class exports.Memory extends Backbone.Model
  
  urlRoot: '/memories'
  
  defaults:
    favoriteOf: []
    
    title: null
    date: null
    description: null
    
    friends: []
    
    photos: []
    
exports.Timeline =
  API: 'http://localhost:8080'

  sync: (method, model, options) ->
    
    # Default JSON-request options
    type = {create: 'POST', update: 'PUT', delete: 'DELETE', read: 'GET'}[method]
    params = _.extend {type}, options

    # Construct the full cross-domain API URL
    params.url = Timeline.API + if !params.url then getUrl(model) else params.url

    # Ensure appropriate request data
    if !params.data and model and (method == 'create' or method == 'update')
      params.data = JSON.stringify model.toJSON()
      
    $.ajax params
    
memoriesNewTemplate = require('templates/memories/memories_new')

class exports.MemoriesNewView extends Backbone.View
  id: 'memories_new'
  
  events:
    'click #end_date a'  : 'enableDateRange'
    'click #tag_friends' : 'showFriendSelector'
    'submit form'        : 'createMemory'
  
  render: ->
    $view = $(@.el).html(memoriesNewTemplate())
    
    birthday =
      'year'  : 1982
      'month' : 11
      'day'   : 27
    
    $view.find('.datepicker').each(->
      $this = $(this)
      
      # Invoke the jQuery UI datepickers
      options =
        'showOn'          : 'both'
        'buttonImage'     : '/web/img/calendar.gif'
        'buttonImageOnly' : true
        'changeMonth'     : true
        'changeYear'      : true
        'dayNamesMin'     : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        'showAnim'        : ''
        'altFormat'       : 'yy-mm-dd'
        'altField'        : '#'+$(this).attr('id').slice(0, -6)
        'maxDate'         : 0
        'minDate'         : new Date(birthday.year, birthday.month, birthday.day)
        'yearRange'       : birthday.year.toString()+':-nn:+nn'
      $this.datepicker(options)
    )
    
    # Second date in the range must be >= the first
    $view.find('.datepicker').first().change(->
      $this = $(this)
      date = $this.datepicker('getDate')
      endDate = $view.find('.datepicker').last()
      endDate.datepicker('option', 'minDate', date)
      endDate.datepicker('option', 'yearRange', date.getFullYear().toString()+':-nn+nn')
    )
    
    # In an error state, populate the visible datepickers with dates from the hidden (actual) date fields
    $startDate = $('#start_date')
    if $startDate.val()
      date = $startDate.val().split('-')
      defaultDate = date[1]+'/'+date[2]+'/'+date[0]
      $('#start_datepicker').val(defaultDate)
    $endDate = $('#end_date')
    if $endDate.val()
      date = $endDate.val().split('-')
      defaultDate = date[1]+'/'+date[2]+'/'+date[0]
      $('#end_datepicker').val(defaultDate)
      $('#end_date a').trigger('click')
    
    # In an error state, populate the visible datepickers with dates from the hidden (actual) date fields
    for $dateField in [$('#start_date'), $('#end_date')]
      if $dateField.val()
        date = $dateField.val().split('-')
        defaultDate = date[1]+'/'+date[2]+'/'+date[0]
        $('#'+$dateField.attr('id')+'picker').val(defaultDate)
        $('#end_date a').trigger('click') if $dateField.attr('id') == 'end_date'
    
    @
  
  enableDateRange: (e) ->
    e.preventDefault()
    $link = $(e.currentTarget)
    
    $link.siblings().each(->
      $(this).removeClass('hide').show()
    )
    $link.remove()
    
  showFriendSelector: (e) ->
    e.preventDefault()
    $('<div id="friend_selector"></div>')
      .friendSelector($(e.currentTarget), $('#friends'), [{'id': 1, 'name': 'Ryan McKillen'}])
      .dialog('Tag Friends')
      
  createMemory: (e) ->
    e.preventDefault()
    console.log('create')
    
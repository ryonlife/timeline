exports.helpers =
  
  datepickers: ->
    # jQuery UI Datepickers need to be be in the DOM to work, so just calling this from routers until I have a better idea
    
    # Datepicker updates the value of an input, but I want to update the text of a non-input HTML element
    duckPunch = (inst) ->
      altField = this._get(inst, 'altField')
      if altField
        altFormat = this._get(inst, 'altFormat') || this._get(inst, 'dateFormat')
        date = this._getDate(inst)
        dateStr = this.formatDate(altFormat, date, this._getFormatConfig(inst))
        $(altField).each -> $(this).text(dateStr)
    $.extend($.datepicker.__proto__, {_updateAlternate: duckPunch})
  
    # Initialize the jQuery UI datepickers
    that = @
    $('.datepicker').each ->
      $this = $(@)
      birthdayParts = '11/27/1982'.split('/')
      options =
        showOn: 'both'
        changeMonth: true
        changeYear: true
        dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        showAnim: ''
        altFormat: 'MM d, yy'
        dateFormat: 'yy-mm-dd'
        altField: '#'+$(this).attr('id').slice(0, -6)
        maxDate: 0
        minDate: new Date(birthdayParts[2], birthdayParts[0] - 1, birthdayParts[1])
        yearRange: birthdayParts[2].toString()+':-nn:+nn'
      $this.datepicker options
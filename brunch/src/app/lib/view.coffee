Backbone.View = Backbone.View.extend
  
  qtips: ->
    $el = $(@el)
    $el.find('a[title]').qtip
      position:
        my: 'top right'
        at: 'bottom left'
        adjust:
          x: 5
      style:
        classes: 'ui-tooltip-dark ui-tooltip-shadow'
    $el.find('label').css('display', 'block') if not Modernizr.input.placeholder

  xfbml: ->
    FB.XFBML.parse document.getElementById @id
  
  datepickers: ->
    # jQuery UI Datepickers need to be be in the DOM and visible on screen to work

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
      birthdayParts = USER.ME.birthday.split('/')
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
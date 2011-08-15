memoriesShowHeaderTemplate = require('templates/memories/memories_show_header')

class exports.MemoriesShowHeaderView extends Backbone.View
  id: 'memories_show_header_view'
  className: 'clearfix'
  
  events:
    'click #edit': 'editMemory'
    'submit #memory_edit form': 'updateTitleDescriptionDate'
    'click input[type=button]': 'cancelUpdateTitleDescriptionDate'
    'click #favorite': 'updateFavorite'
  
  initialize: ->
    _.bindAll @, 'render'
    @model.bind 'change', @render
  
  render: ->
    $el = $(@el)
    
    $el.html memoriesShowHeaderTemplate {model: @model}
    
    $el.find('a[title]').qtip
      position:
        my: 'top right'
        at: 'bottom left'
        adjust:
          x: 5
      style:
        classes: 'ui-tooltip-dark ui-tooltip-shadow'
    $el.find('label').css('display', 'block') if not Modernizr.input.placeholder
    
    @
    
  editMemory: (e) ->
    e.preventDefault()

    $('#edit_title').val($('#title').text())
    $('#edit_description').val($('#description').text())

    model = @model
    $('.datepicker').datepicker('setDate', model.get('date'))

    $('#edit').first().qtip('toggle')

    $('#memory_header').hide()
    $('#memory_edit').fadeIn()

  updateTitleDescriptionDate: (e) ->
    e.preventDefault()

    title = $.trim($('#edit_title').val())
    date = $.datepicker.formatDate 'yy-mm-dd', $('#start_datepicker').datepicker('getDate')
    description = $.trim($('#edit_description').val())

    if title and description
      @model.set
        title: title
        date: date
        description: description

      @model.save()

      $('#title').text(title)
      $('#description').text(description)

      $('#memory_edit').hide()
      $('#memory_header').fadeIn()

  cancelUpdateTitleDescriptionDate: (e) ->
    model = @model
    $('#start_date').text(model.formatDate())
    $('#memory_edit').hide()
    $('#memory_header').fadeIn()

  updateFavorite: (e) ->
    e.preventDefault()
    $el = $(e.currentTarget)

    favoriteOf = @model.get 'favoriteOf'
    if $el.attr('data-favorite') == 'true'
      $el
        .attr('title', 'Add this memory to your favorites.')
        .attr('data-favorite', 'false')
        .css('opacity', 0.5)
      favoriteOf = _.without favoriteOf, USER.ME.id
    else
      $el
        .attr('title', 'Remove this memory from your favorites.')
        .attr('data-favorite', 'true')
        .css('opacity', 1)
      favoriteOf.push USER.ME.id
    @model.set {favoriteOf: favoriteOf}
      
class exports.MemoriesController extends Backbone.Controller
  routes:
    'memories_new': 'new'

  constructor: ->
    super

  new: ->
    $('#fb_wrapper').html app.views.memories_new.render().el
    
    birthday =
      'year': 1982
      'month': 11
      'day': 27
    
    `$('.datepicker').each(function() {
      var $this = $(this);
      $this.datepicker({
        showOn:          'both',
        buttonImage:     '/web/img/calendar.gif',
        buttonImageOnly: true,
        changeMonth:     true,
        changeYear:      true,
        dayNamesMin:     ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        showAnim:        '',
        altFormat:       'yy-mm-dd',
        altField:        '#event_'+$(this).attr('id').slice(0, -11)+'_date',
        maxDate:         0,
        minDate:         new Date(birthday.year, birthday.month, birthday.day),
        yearRange:       birthday.year.toString()+':-nn:+nn', 
     });
    });`

$(function() {
  
  // Orientation via data-attrs
  var where = {controller: $('h1.data').attr('data-controller'), action: $('h1.data').attr('data-action'), id: $('h1.data').attr('data-id')};
  
  // jQuery UI datepicker
  $('.datepicker').each(function() {
    var $this = $(this);
    $this.datepicker({
      showOn:          'both',
      buttonImage:     '/images/calendar.gif',
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
  });
  
  // Enable a range of dates
  $('span#end_date a').click(function() {
    var $this = $(this);
    $this.siblings().each(function() {
      $(this).removeClass('hide').show()
    });
    $this.remove();
    return false;
  });
  
  // Second date in range must be >= the first
  $('.datepicker').first().change(function() {
    var date = $(this).datepicker('getDate');
    var endDate = $('.datepicker').last();
    endDate.datepicker('option', 'minDate', date);
    endDate.datepicker('option', 'yearRange', date.getFullYear().toString()+':-nn:+nn');
    $('.ui-datepicker-trigger').show(); // WTF: calendar trigger icon disappears
  });
  
  // In an error state, populate the visible datepickers with dates from the hidden (actual) date fields
  $start_date = $('#event_start_date');
  if($start_date.val()) {
    var date         = $start_date.val().split('-');
    var default_date = date[1]+'/'+date[2]+'/'+date[0];
    $('#start_datepicker').val(default_date);
  }
  $end_date = $('#event_end_date');
  if($end_date.val()) {
    var date         = $end_date.val().split('-');
    var default_date = date[1]+'/'+date[2]+'/'+date[0];
    $('#end_datepicker').val(default_date);
    $('span#end_date a').trigger('click');
  }
  
  // Display a friend selector
  var friends;
  var $friendInput = $('#event_friends');
  $('#select_friends').click(function() {
    $this = $(this);
    if(!friends) {
      $.ajax({
        url: '/graph/friends',
        success: function(data) {
          friends = data;
          $('#friend_selector').friendSelector($this, $friendInput, friends).dialog('Tag Friends');
        }
      });
    } else {
      $('#friend_selector').friendSelector($this, $friendInput, friends).dialog('Tag Friends');
    }
  });
  
  // Default state for friend selector button
  if($friendInput.val()) {
    var numFriendsSelected = $friendInput.val().split(',').length;
    $('#select_friends').html('<span class="tag"></span>Tag Friends ('+parseInt(numFriendsSelected+1)+')');
  }
  
  // When the friend selector dialog is closed and friends are changed, update on-screen and on the server
  $('#event_friends.update').change(function() {
    $this = $(this);
    $.ajax({
      type: 'PUT',
      url: '/events/'+where.id,
      data: {_method: 'PUT', friends: $this.val()},
      dataType: 'json',
      success: function(data) {
        console.log(data);
      }
    });
  });
  
  // Cheat for centering stuff
  $('.center_cheat').each(function() {
    $this = $(this);
    $this.css({width: $this.width(), display: 'block'});
  });
  
});

// Callback that fires when FBXML is finished parsing
function XfbmlParsed() {
  $(function() {
    // $fbComments = $('#fb_comments');
    // var offset = $fbComments.offset();
    // console.log(offset.top);
    // console.log($fbComments.height());
    // $('body').append($('<div class="whiteout"></div>').css({top: offset.top + $fbComments.height(), left: offset.left}));
  });
}

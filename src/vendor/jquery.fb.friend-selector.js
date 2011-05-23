(function($) {
  // Facebook-looking friend selector widget
  $.fn.fbFriendSelector = function(friends, selectedFriends) {
    // Setup
    
    var $button = $(this);
    var $fs = $('<div id="friend_selector"></div>');
    $('body').append($fs);

    $fs
      .append('<div id="friend_selector_controls"></div>')
      .append('<ul id="friend_selector_friends" class="clearfix"></ul>')
      .append('<a href="#" class="form_button">Save and Close</a>');

    var $fsc = $('#friend_selector_controls');

    $fsc
      .append('<input id="friend_selector_search" name="friend_selector_search" type="text" placeholder="Type a friend\'s name" />')
      .append('<a href="#" class="show_selected">Selected (0)</a>')
      .append('<a href="#" class="show_all highlight">All</a>')
      .append('<a href="#" class="clear_search"></a>');

    var $fss = $('#friend_selector_search');
    var $fsf = $('#friend_selector_friends');

    var $clear        = $fsc.find('.clear_search');
    var $showAll      = $fsc.find('.show_all');
    var $showSelected = $fsc.find('.show_selected');
    
    $fs.fbDialog('Tag Friends');
    
    // Clear the search box
    $clear
      .css({
        left: -1 * ($clear.offset().left - 7 - $fss.offset().left - $fss.width())
      })
      .click(function() {
        $fss
          .val('')
          .trigger('keyup');
        return false;
      });

    // Show selected friends
    $showSelected.click(function() {
      if(!$showSelected.hasClass('highlight')) {
        $showAll.removeClass('highlight');
        $showSelected.addClass('highlight');
        $clear.trigger('click');
        $fsf.find('li').hide();
        $.each(friends, function(i, friend) {
          if(friend.name.search(new RegExp($fss.val(), 'i')) != -1) {
            var $friend = $fsf.find('li[data-friend-id="'+friend.id+'"]');
            if ($friend.hasClass('selected')) {
              $friend.show();
            }
          }
        });
      }
      return false;
    });

    // Show all friends
    $showAll.click(function() {
      if(!$showAll.hasClass('highlight')) {
        $showSelected.removeClass('highlight');
        $showAll.addClass('highlight');
        $fss.trigger('keyup');
      }
      return false;
    });

    // Put all friends that haven't previously been tagged in the list
    $.each(friends, function() {
      if($.inArray(this.id.toString(), selectedFriends) == -1) {
        var name = this.name.replace(/ /, '<br />');
        $fsf.append('<li data-friend-id="'+this.id+'"><span class="frame"><fb:profile-pic class="image" facebook-logo="false" linked="false" size="square" uid="'+this.id+'"></fb:profile-pic><span class="check"></span></span><span class="name">'+name+'</span></li>');
      }      
    });
    FB.XFBML.parse(document.getElementById($fsf.attr('id'))); // Newly raising unsafe JS frame access when parsing pictures
    updateSelectedCount();

    // Search for friends
    $fss
      .keyup(function() {
        $fsf.find('li').hide();
        $.each(friends, function(i, friend) {
          if(friend.name.search(new RegExp($fss.val(), 'i')) != -1) {
            $fsf.find('li[data-friend-id="'+friend.id+'"]').show();
          }
        });
      })
      .focus(function() {
        $showAll.trigger('click');
      });

    // Select and unselect friends
    $fsf.find('li').click(function() {
      var $this = $(this)
      $this.toggleClass('selected');

      // Hide unselected friends if in the 'show selected' state
      if(!$this.hasClass('selected') && $showSelected.hasClass('highlight')) {
        $this.hide();
      }

      updateSelectedCount();
    });

    // Close button
    $fs.find('.form_button').click(function() {

      friend_ids = [];
      $fsf.find('li.selected').each(function() {
        friend_ids.push($(this).attr('data-friend-id'));
      });

      $button.trigger('friendSelection', [friend_ids])

      // Remove dialog
      $('#dialog').remove();

      return false;
    });

    // Update the selected counter
    function updateSelectedCount() {
      $showSelected.text('Selected ('+$fsf.find('li.selected').length+')');
    }

    return $fs;
  };
})(jQuery);

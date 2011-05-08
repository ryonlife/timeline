(function($) {
    
  // Facebook-looking gallery widget
  $.fn.fbGallery = function() {
    
    // Setup
    
    var $this = $(this);
    
    var $gallery = $('<div id="fb_gallery"><div></div></div>');
    $gallery.appendTo('body');
    
    // Hack to get the dark mat horizontally centered
    $gallery.find('div').css({'left': $('#fb_wrapper').offset().left + 2});
    
    // Markup for image and arrows
    $gallery
      .find('div')
        .append($('<a href="#" class="left"></a>'))
        .append($('<span><img src="'+$this.attr('href')+'" /></span>'))
        .append($('<a href="#" class="right"></a>'))
        .append($('<a href="#" class="close"></a>'))
        
    // Horizontally center the image and vertically center the arrows
    var $img = $gallery.find('img');
    $img.css({'width': $img.width(), 'height': $img.height()});
    $gallery.find('a.left, a.right').css({'height': $img.height()});
    
    // Close button
    $gallery.find('.close').click(function() {
      $gallery.remove();
      return false;
    });
    
    return this;
  }
  
})(jQuery);

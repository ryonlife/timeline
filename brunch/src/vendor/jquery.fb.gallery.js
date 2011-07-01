(function($) {
  
  // Facebook-looking gallery widget
  $.fn.fbGallery = function() {
    
    // Setup
    var $this = $(this);
    var $gallery = $('<div id="fb_gallery"><div></div></div>');
    $gallery.appendTo('body');
    
    // Hack to get the dark mat horizontally centered
    $gallery.find('div').css({'left': $('#fb_wrapper').offset().left});
    
    // Markup for image and arrows
    $gallery
      .find('div')
        .append($('<a href="#" class="left"></a>'))
        .append($('<div style="background-image: url('+$this.attr('href')+');"></div>'))
        .append($('<a href="#" class="right"></a>'))
        .append($('<a href="#" class="close"></a>'))
    
    // Close button
    $gallery.find('.close').click(function() {
      $gallery.remove();
      return false;
    });
    
    // Create an array of pictures in the gallery, and determine the starting position based on the pic that launched the gallery
    var $pics = $('a.fb_gallery');
    var pos;
    picUrls = [];
    $pics.each(function() {
      var picUrl = $(this).attr('href');
      var length = picUrls.push(picUrl);
      if (picUrl == $this.attr('href')) {
        pos = length - 1;
      }
    });
    
    $gallery.find('a.left, a.right').each(function() {
      $(this).click(function() {
        if ($(this).hasClass('right')) {
          var showPos = pos + 1 >= picUrls.length ? 0 : pos + 1;
        } else {
          var showPos = pos - 1 < 0 ? picUrls.length - 1 : pos - 1;
        }
        $gallery.find('div div').css({backgroundImage: 'url('+picUrls[showPos]+')'});
        pos = showPos;
        // center();
        return false;
      });
    });
    
    return this;
  }
  
})(jQuery);

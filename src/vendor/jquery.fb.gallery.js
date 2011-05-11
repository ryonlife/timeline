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
    function center() {
      var img = new Image;
      img.onload = function() {
        $gallery.find('img').css({'width': this.width, 'height': this.height});
        $gallery.find('a.left, a.right').css({'height': this.height});
        console.log(this.width);
        console.log(this.height);
      }
      img.src = $this.attr('href');
    }
    center();
    
    // Close button
    $gallery.find('.close').click(function() {
      $gallery.remove();
      return false;
    });
    
    // Create an array of pictures in the gallery, and determine the starting position based on the pic that launched the gallery
    var $pics = $this.parents('ul').find('a.fb_gallery');
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
        $gallery.find('img').remove();
        $gallery.find('span').html('<img src="'+picUrls[showPos]+'" />');
        pos = showPos;
        center();
        return false;
      });
    });
    
    return this;
  }
  
})(jQuery);

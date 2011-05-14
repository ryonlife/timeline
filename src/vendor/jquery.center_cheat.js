(function($) {
  jQuery.centerCheat = function() {
    
    $('.h_center_cheat:visible').each(function() {
      $this = $(this);
      $this.css({width: $this.width(), display: 'block', margin: '0 auto'});
    });
    
    $('.v_center_cheat:visible').each(function() {
      $this = $(this);
      $this.css({'margin-top': $this.parent().height() / 2 - $this.height() / 2});
    });
      
  }
})(jQuery);

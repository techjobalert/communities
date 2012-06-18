(function( $ ){
  $.fn.blinkText = function() {
    this.animate({opacity:0},200,"linear",function(){
      $(this).animate({opacity:1},200);
  });
  }
 })( jQuery );
$(document).ready(function(){ 
  $('.parallax-image').parallax("50%", 0.1);
  $('.parallax-image2').parallax("50%", 0.1);
  $('.parallax-image3').parallax("50%", 0.1);

   $(".click-me a[href^='#']").on('click', function(e) {
    e.preventDefault();
    $('html, body').animate({
        scrollTop: $(this.hash).offset().top-70
    }, 1000);
  });
});

$(window).scroll(function() {    
  var scroll = $(window).scrollTop();

  if (scroll >= 10) {
      $(".transparent").addClass("scrolling");
      $("#logo-color").removeClass("hide");

      $("#logo-white").addClass("hide");
      $("#logo-white").removeClass("show");

      $(".btn-border").addClass("hide");
      $(".btn-border").removeClass("show");

      $(".btn-orange2").removeClass("hide");
  } else {
      $(".transparent").removeClass("scrolling");
      // $("#logo-color").addClass("hide");
      $("#logo-white").removeClass("hide");
      $("#logo-white").addClass("show");

      $("#logo-color").addClass("hide");

      $(".btn-border").removeClass("show");
      $(".btn-border").addClass("show");

      $(".btn-orange2").addClass("hide");
  }
});


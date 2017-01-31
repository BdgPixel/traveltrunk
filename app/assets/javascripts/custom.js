var initParalax = function() {
  $('.parallax-image').parallax("50%", 0.1);
  $('.parallax-image2').parallax("50%", 0.1);
  $('.parallax-image3').parallax("50%", 0.1);

   $(".click-me a[href^='#']").on('click', function(e) {
    e.preventDefault();
    $('html, body').animate({
        scrollTop: $(this.hash).offset().top-70
    }, 1000);
  });

   $(".bank_account a[href^='#']").on('click', function(e) {
    e.preventDefault();
    $('html, body').animate({
        scrollTop: $(this.hash).offset().top-60
    }, 1000);
  });
};

var initScrolling = function() {
  var controller = $('body').data('controller')
  var action = $('body').data('action')

  if (controller == 'home' && action == 'search') {
    $(".transparent").addClass("scrolling");
    $(".btn-border").removeClass("show");
    $(".btn-border").addClass("show");

    $(".btn-orange2").addClass("hide");
  } else {
    $(window).scroll(function() {
      var scroll = $(window).scrollTop();

      if (scroll >= 10) {
        $(".transparent").addClass("scrolling");
        $("#logo-color-orange").removeClass("hide");

        $("#logo-color-white").addClass("hide");
        $("#logo-color-white").removeClass("");

        $(".btn-border").addClass("hide");
        $(".btn-border").removeClass("show");

        $(".btn-orange2").removeClass("hide");
        $(".link-top-login").addClass('grey-nav-color');
      } else {
        if ($("#bs-example-navbar-collapse-1").hasClass('in') === false) {

          $(".transparent").removeClass("scrolling");
          $("#logo-color-white").removeClass("hide");
          $("#logo-color-white").addClass("");

          $("#logo-color-orange").addClass("hide");

          $(".btn-border").removeClass("show");
          $(".btn-border").addClass("show");

          $(".btn-orange2").addClass("hide");
          $(".link-top-login").removeClass('grey-nav-color');
        }
      }
    });
  }
};

var ready = function() {
  initParalax();
  initScrolling();
};

$(document).ready(function() {
  ready();
});

$(document).on('page:load', function() {
  ready();
});

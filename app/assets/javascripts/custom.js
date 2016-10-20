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
      $(".transparent").removeClass("scrolling");
      $("#logo-color-white").removeClass("hide");
      $("#logo-color-white").addClass("");

      $("#logo-color-orange").addClass("hide");

      $(".btn-border").removeClass("show");
      $(".btn-border").addClass("show");

      $(".btn-orange2").addClass("hide");
      $(".link-top-login").removeClass('grey-nav-color');
  }
};

var initToolTip = function() {
  $("body").tooltip({
    selector: "[data-toggle='tooltip']",
    container: "body"
  })
    //Popover, activated by clicking
    .popover({
    selector: "[data-toggle='popover']",
    container: "body",
    html: true
  });
};

var initSwipeGroupSaving = function() {
  $('.swipe-group-saving').slick({
    dots: false,
    infinite: false,
    speed: 300,
    slidesToShow: 3,
    slidesToScroll: 3,
    arrows: true,
    variableWidth: true,
    responsive: [
      {
        breakpoint: 960,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: true,
          variableWidth: false,
          arrows: true,
          dots: false
        }
      },
      {
        breakpoint: 1024,
        settings: {
          slidesToShow: 3,
          slidesToScroll: 3,
          infinite: true,
          variableWidth: false,
          arrows: true,
          dots: false
        }
      },

      {
        breakpoint: 600,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          variableWidth: false,
          arrows: true,
        }
      },
      {
        breakpoint: 480,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          arrows: true,
          variableWidth: false
        }
      }
      // You can unslick at a given breakpoint now by adding:
      // settings: "unslick"
      // instead of a settings object
    ]
  });
};

var ready = function() {
  initParalax();
  initScrolling();
  initToolTip();
  initSwipeGroupSaving();
};

$(document).ready(function() {
  ready()
});

$(document).on('page:load', function() {
  ready();
});

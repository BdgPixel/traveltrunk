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

   $(".bank_account a[href^='#']").on('click', function(e) {
    e.preventDefault();
    $('html, body').animate({
        scrollTop: $(this.hash).offset().top-60
    }, 1000);
  });
});

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
      $(".transparent").removeClass("scrolling");
      $("#logo-color-white").removeClass("hide");
      $("#logo-color-white").addClass("");

      $("#logo-color-orange").addClass("hide");

      $(".btn-border").removeClass("show");
      $(".btn-border").addClass("show");

      $(".btn-orange2").addClass("hide");
      $(".link-top-login").removeClass('grey-nav-color');
  }
});

/*
  We can use [body] or the element class/id that wraps the elements with tooltip/popover.
  Include the data-[] attribute in each element that needs it.
*/
$(document).ready(function () {
  //can also be wrapped with:
  //1. $(function () {...});
  //2. $(window).load(function () {...});
  //3. Or your own custom named function block.
  //It's better to wrap it.

  //Tooltip, activated by hover event
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
  //They can be chained like the example above (when using the same selector).

});
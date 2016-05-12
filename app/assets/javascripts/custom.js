$(document).ready(function(){
  $('.owl-carousel').owlCarousel({
      loop:true,
      margin:10,
      responsiveClass:true,
      responsive:{
          0:{
              items:1,
              nav:false
          },
          600:{
              items:1,
              nav:false
          },
          1000:{
              items:1,
              nav:false,
              loop:false
          }
      }
  });

  $('.parallax-image').parallax("50%", 0.5);

});

$(window).scroll(function() {    
  var scroll = $(window).scrollTop();

  if (scroll >= 500) {
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

// $(window).scroll(function(){

//     // Add parallax scrolling to all images in .paralax-image container
//       $('.parallax-image').each(function(){
//         // only put top value if the window scroll has gone beyond the top of the image
//             if ($(this).offset().top < $(window).scrollTop()) {
//             // Get ammount of pixels the image is above the top of the window
//             var difference = $(window).scrollTop() - $(this).offset().top;
//             // Top value of image is set to half the amount scrolled
//             // (this gives the illusion of the image scrolling slower than the rest of the page)
//             var half = (difference / 2) + 'px';

//             $(this).find('img').css('top', half);
//         } else {
//             // if image is below the top of the window set top to 0
//             $(this).find('img').css('top', '0');
//         }
//       });
// });
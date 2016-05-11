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
  })
});

$(window).scroll(function() {    
  var scroll = $(window).scrollTop();

  if (scroll >= 500) {
      $(".transparent").addClass("scrolling");
  } else {
      $(".transparent").removeClass("scrolling");
  }
});

$(window).scroll(function() {   
  $(window).stellar();
});
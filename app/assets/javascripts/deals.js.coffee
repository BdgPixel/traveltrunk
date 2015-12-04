# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require jquery.bootpag
# = require blueimp-gallery
# = require blueimp-gallery-indicator
# = require jquery.lazyload
# = require bootstrap-datepicker
# = require holder
# = require google-api
# = require jquery.raty
# = require jquery.raty-fa
# = require ratyrate


# js not used
# require galleria

cid = 55505
apiKey = '5fd6485clmp3oogs8gfb43p2uf'
url_image = "http://images.travelnow.com"

getFormattedDate = (date) ->
  day = date.getDate()
  month = date.getMonth() + 1
  year = date.getFullYear()
  formattedDate = [month, day, year].join('/')

  formattedDate

today = getFormattedDate(new Date)

disableEnterFormSubmit = ->
  $('#searchDealsForm').on 'keyup keypress', (e) ->
    code = e.keyCode or e.which
    if code == 13
      e.preventDefault()

      return false

    return

  return

validateSearchForm = ->
  $('#searchDealsForm').validate
    ignore: ".ignore"
    rules:
      autocomplete: 'required'

    messages:
      autocomplete: 'Please enter your destination'

  return

# loadMoreHotels = (cacheKey, cacheLocation, pageNumber) ->

#   page = $(".deals-page[data-page='#{ pageNumber }']")

#   if page.length > 0
#     page.show()
#     $('.deals-page').not(page).hide()
#   else
#     $('div.deals-image').removeClass 'lazy'
#     url = "http://api.ean.com/ean-services/rs/hotel/v3/list?cid=#{ cid }&minorRev=28&apiKey=#{ apiKey }&locale=en_US&cacheKey=#{cacheKey}&cacheLocation=#{cacheLocation}&supplierType=E"

#     $.ajax
#       url: url
#       type: 'GET'
#       dataType: 'jsonp'
#       beforeSend: ->
#         $('#loading').show()
#       success:  (data) ->
#         $('#loading').fadeOut("slow")
#         $('.deals-page').hide()

#         previousPageNumber = $('.deals-page').length
#         currentPageNumber =  previousPageNumber + 1
#         nextPageNumber = currentPageNumber + 1

#         # $('#dealsHotelsList .col-deals').remove()

#         $('#loadMoreNext').attr('data-cache-key', data['HotelListResponse']['cacheKey'])
#         $('#loadMoreNext').attr('data-cache-Location', data['HotelListResponse']['cacheLocation'])

#         dealsPage = $("<div class='deals-page' data-page='#{ currentPageNumber }' >")
#         $.each data["HotelListResponse"]["HotelList"]["HotelSummary"], (key, hotel) ->
#           roundedPrice = Math.round(hotel["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@averageRate"])
#           dealsWrapper = $('<div class="wrapper-price-deals">')
#           dealsGrid = $('<div class="col-xs-6 col-md-4 col-deals">')
#           dealsGrid.append $("<div class='price-deals'><strong>$#{ roundedPrice }</strong></div>")
#           dealsGrid.append $("<a href='/deals/#{ hotel['hotelId'] }/show?price=#{ roundedPrice }' data-no-turbolink='true'><div class='lazy deals-image' data-original='#{ url_image }#{ hotel['thumbNailUrl'].replace('_t.', '_y.') }' style=\"background:url('#{ window.default_image_path }') no-repeat; background-size: 100% 100%; height: 300px;\"></div></a>")
#           dealsGrid.append $("<div class='col-md-10'><p class='text-center content-deals'><a href='/deals/#{ hotel['hotelId'] }/show?price=#{ roundedPrice }' data-toggle='tooltip' data-placement='top' data-title='#{ hotel['name'].toUpperCase() }' data-no-turbolink='true'>#{ hotel['name'].toUpperCase() }</a></p></div>")
#           dealsGrid.append $("<div class='col-md-2'><div class='wrapper-like-deals'><p id='likeDeal' class='text-right content-deals'><a href='/deals/#{ hotel['hotelId'] }/like' data-remote='true'><span class='icon love-normal' id='like-#{ hotel['hotelId'] }'></span></a></p></div></div>")
#           dealsWrapper.append dealsGrid
#           dealsPage.append dealsWrapper
#         dealsPage.append $("<div class='col-md-12'><div class='pull-right'><a class='btn btn-orange loadMoreBack' data-previous-page='#{ previousPageNumber }'><i class='icon previous-loadmore pull-left'></i>&nbsp;&nbsp;Back</a><a class='btn btn-orange loadMoreNext' data-cache-key='#{ data['HotelListResponse']['cacheKey'] }' data-cache-Location='#{ data['HotelListResponse']['cacheLocation'] }' data-next-page='#{ nextPageNumber }' >Next<i class='icon next-loadmore'></i></a></div></div><br><br>")
#         $('#dealsHotelsList').append dealsPage

#         $('div.lazy').lazyload
#           effect : 'fadeIn'

#         $('[data-toggle="tooltip"]').tooltip()

#         $(".loadMoreNext[data-next-page='#{ nextPageNumber }']").on 'click', ->
#           loadMoreHotels($(this).attr('data-cache-key'), $(this).attr('data-cache-location'), $(this).data('next-page'))

#         $(".loadMoreBack[data-previous-page='#{ previousPageNumber }']").on 'click', ->
#           targetPageNumber = $(this).data('previous-page')
#           targetPage = $(".deals-page[data-page='#{ targetPageNumber }']")
#           $('.deals-page').not(targetPage).hide()
#           targetPage.show()

#   return

searchDestination = ->
  lat = $('#lat').val()
  lng = $('#lng').val()
  arrivalDate = $('#search_deals_arrival_date').val()
  departureDate = $('#search_deals_departure_date').val()

  url = "http://api.ean.com/ean-services/rs/hotel/v3/list?cid=#{ cid }&minorRev=28&apiKey=#{ apiKey }&locale=en_US&currencyCode=USD&latitude=#{ lat }&longitude=#{ lng }&arrivalDate=#{ arrivalDate }&departureDate=#{ departureDate }&options=HOTEL_SUMMARY,ROOM_RATE_DETAILS&searchRadius=80&numberOfResults=21"
  $.ajax
    url: url
    type: 'GET'
    dataType: 'jsonp'
    beforeSend: ->
      $('#loading').show()
    success:  (data) ->
      $('#dealsHotelsList').html ''

      previousPageNumber = $('.deals-page').length
      currentPageNumber =  previousPageNumber + 1
      nextPageNumber = currentPageNumber + 1

      $('#slideToggleLink').text $('#autocomplete').val().split(',')[0]

      dealsPage = $("<div class='deals-page' data-page='#{ currentPageNumber }' >")
      $.each data['HotelListResponse']['HotelList']['HotelSummary'], (key, hotel) ->
        roundedPrice = Math.round(hotel["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@averageRate"])
        dealsWrapper = $('<div class="wrapper-price-deals">')
        dealsGrid = $('<div class="col-xs-6 col-md-4 col-deals">')
        dealsGrid.append $("<div class='price-deals'><strong>$#{ roundedPrice }</strong></div>")
        dealsGrid.append $("<a href='/deals/#{ hotel['hotelId'] }/show?price=#{ roundedPrice }' data-no-turbolink='true'><div class='lazy deals-image' data-original='#{ url_image }#{ hotel['thumbNailUrl'].replace('_t.', '_y.') }' style=\"background:url('#{ window.default_image_path }') no-repeat; background-size: 100% 100%; height: 300px;\"></div></a>")
        dealsGrid.append $("<div class='col-md-10'><p class='text-center content-deals'><a href='/deals/#{ hotel['hotelId'] }/show?price=#{ roundedPrice }' data-toggle='tooltip' data-placement='top' data-title='#{ hotel['name'].toUpperCase() }' data-no-turbolink='true'>#{ hotel['name'].toUpperCase() }</a></p></div>")
        dealsGrid.append $("<div class='col-md-2'><div class='wrapper-like-deals'><p id='likeDeal' class='text-right content-deals'><a href='/deals/#{ hotel['hotelId'] }/like' data-remote='true'><span class='icon love-normal' id='like-#{ hotel['hotelId'] }'></span></a></p></div></div>")
        dealsWrapper.append dealsGrid
        dealsPage.append dealsWrapper

      dealsPage.append $("<div class='col-md-12'><div class='pull-right'><a class='btn btn-orange loadMoreNext' data-cache-key='#{ data['HotelListResponse']['cacheKey'] }' data-cache-Location='#{ data['HotelListResponse']['cacheLocation'] }' data-next-page='#{ nextPageNumber }' >Next<i class='icon next-loadmore'></i></a></div></div><br><br>")
      $('#dealsHotelsList').append dealsPage

      arrivalDate = new Date($('#search_deals_arrival_date').val())
      departureDate = new Date($('#search_deals_departure_date').val())
      arrivalDate = [arrivalDate.getFullYear(), arrivalDate.getMonth() + 1, arrivalDate.getDate()].join('/')
      departureDate = [departureDate.getFullYear(), departureDate.getMonth() + 1, departureDate.getDate()].join('/')

      $.ajax
        url: '/deals/create_destination'
        type: 'POST'
        data:
          destinationString: $('#autocomplete').val()
          city: $('#locality').val()
          stateProvinceCode: $('#administrative_area_level_1').val()
          countryCode: $('#country').val()
          lat: $('#lat').val()
          lng: $('#lng').val()
          arrivalDate: arrivalDate
          departureDate: departureDate
        success:  (data) ->
          $('#loading').fadeOut("slow");

      # $('div.lazy').lazyload
      #   effect : 'fadeIn'

      $('#collapseDeals').slideToggle()
      $('[data-toggle="tooltip"]').tooltip()

      $(".loadMoreNext[data-next-page='#{ nextPageNumber }']").on 'click', ->
        loadMoreHotels($(this).attr('data-cache-key'), $(this).attr('data-cache-location'), $(this).data('next-page'))

  return

listOfMonts = (month) ->
  months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  months[month]

roomSelected = ->
  $('.room-selected').on 'click', ->
    rateCode = $(this).data('rate-code')
    roomTypeCode = $(this).data('room-type-code')
    numberOfRoomsRequested = rooms.numberOfRoomsRequested

    $('.bs-example-modal-lg').modal({ backdrop: 'static' })
    $('.modal .modal-header h3').text(rooms.hotelName)
    $('.modal .modal-body .row .col-md-12 .col-md-6 #roomRating').attr('data-rating', rooms.tripAdvisorRating)
    $('.modal .modal-body .row .col-md-12 .col-md-6 .rating-text').text(rooms.tripAdvisorRating + " ratings")
    $('.modal .modal-body .row .col-md-12 .col-md-6 .hotel-info-addr').text(rooms.hotelAddress)
    $('.modal .modal-body .row .col-md-12 .col-md-6 .hotel-info-city').html("&nbsp;City&nbsp; #{rooms.hotelCity}")
    $('.modal .modal-body .row .col-md-12 .col-md-6 .hotel-info-state').html("&nbsp;State&nbsp; #{rooms.hotelStateProvince}")
    $('.modal .modal-body .row .col-md-12 .col-md-6 .hotel-info-country').html("&nbsp;Country&nbsp; #{rooms.hotelCountry}")
    $('.modal .modal-body .row .col-md-12 .col-md-6 .checkin-intructions').html(rooms.checkInInstructions)

    $('#confirmation_book_hotel_id').val($(this).data('id'))
    $('#confirmation_book_arrival_date').val(rooms.arrivalDate)
    $('#confirmation_book_departure_date').val(rooms.departureDate)
    $('#confirmation_book_rate_code').val(rateCode)
    $('#confirmation_book_room_type_code').val(roomTypeCode)

    room = $.grep(rooms.HotelRoomResponse, (e, index) ->
      e.rateCode == rateCode
    )

    arrivalDate = new Date(rooms.arrivalDate)
    departureDate = new Date(rooms.departureDate)
    dates = []
    d = arrivalDate

    while d <= departureDate
      dates.push(new Date(d))
      d.setDate d.getDate() + 1

    dates.pop()
    table = $("table.table:last tbody")
    table.html('')

    $.each dates, (key, date) ->
      month = listOfMonts(date.getMonth())
      table.append("<tr><td>#{month} #{date.getDate()}, #{date.getFullYear()}</td><td>#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@averageRate']}</td></tr>")

    table.append("<tr><td><b>Total taxes and fees</b></td><td>#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@surchargeTotal']}</td></td>")
    table.append("<tr><td><b>Total</b></td><td>#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@total']}</td></tr>")

    $('#confirmation_book_total').val(room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@total'])
    $('#confirmation_book_rate_key').val(room[0]['RateInfos']['RateInfo']['RoomGroup']['Room']['rateKey'])

    if room[0]['RoomImages']
      if room[0]["RoomImages"]["@size"] == ("1")
        $('#roomImage').attr('src', room[0]['RoomImages']['RoomImage']['url'])
      else
        $('#roomImage').attr('src', room[0]['RoomImages']['RoomImage'][0]['url'])
    else
      $('#roomImage').attr('src', window.default_no_image_thumb_path)

    if room[0]['BedTypes']['@size'] == '1'
      $('#confirmation_book_bed_type').val(room[0]['BedTypes']['BedType']['@id'])
    else
      $('#confirmation_book_bed_type').val $.map(room[0]['BedTypes']['BedType'], (b) ->
        b['@id']
      )

    if $('#roomRating').length > 0
      rating_count = parseFloat($('#roomRating').data('rating'))
      $('div#roomRating').raty
        half   : true
        readOnly: true
        score: rating_count


$ ->
  $('input#search_deals_arrival_date').datepicker(
    startDate: today
    autoclose: true).on 'changeDate', (e) ->
      $('input#search_deals_departure_date').datepicker('remove')
      $('input#search_deals_departure_date').datepicker
        startDate:  getFormattedDate(e.date)
        autoclose: true
      setTimeout(->
        $('input#search_deals_departure_date').datepicker('show')
      , 100)

  $('input#search_deals_departure_date').datepicker
    startDate: today
    autoclose: true

  return

$(document).ready ->
  if window.location.pathname == '/' or window.location.pathname == '/deals' or window.location.pathname == '/deals/'
    $.get '/deals'
  else
    params_path_id = window.location.pathname.split('/')[2]
    $.get "/deals/#{ params_path_id }/room_availability", ->
      roomSelected()
      return

  disableEnterFormSubmit()
  validateSearchForm()

  if $('#slideToggleLink').length > 0
    $('#slideToggleLink').on 'click', (e) ->
      $('#slideToggle').slideDown()
      return

    $('.slide').on 'click', (e) ->
      if e.target != this
        return
      $('#slideToggle').slideUp()
      return

  # if $('#galleria').length > 0
  #   Galleria.loadTheme window.galleria_theme_path
  #   Galleria.configure dummy: '/assets/default-no-image.png'
  #   Galleria.configure showInfo: false
  #   # Initialize Galleria
  #   Galleria.run '#galleria'

  # if $('[data-toggle="tooltip"]').length > 0
  #   $('[data-toggle="tooltip"]').tooltip()

  # if $('div.lazy').length > 0
  #   $('div.lazy').lazyload
  #     effect : 'fadeIn'

  if $('.loadMoreNext').length > 0
    $('.loadMoreNext').on 'click', -> loadMoreHotels($(this).attr('data-cache-key'), $(this).attr('data-cache-location'), $(this).attr('data-next-page'))

  # if $('form#searchDealsForm').length > 0
  #   $('form#searchDealsForm').submit (e) ->
  #     searchDestination()
  #     e.preventDefault()

  if $('#btnClearText').length > 0
    $('#btnClearText').click ->
      $('input#autocomplete').val ''

      return

  if $('#links').length > 0
    blueimp.Gallery document.getElementById('links').getElementsByTagName('a'),
      container: '#blueimp-gallery-carousel'
      carousel: true

  if $('#hotelRating').length > 0
    rating_count = parseFloat($('#hotelRating').data('rating'))

    $('div#hotelRating').raty
      half   : true
      readOnly: true
      score: rating_count


    # $('#hotelRating').raty
    #   half: true
    #   readOnly: true
    #   size: 24
    #   score: rating_count
    #   starOn: window.star_on_mid_image_path
    #   starOff: window.star_off_mid_image_path
    #   starHalf: window.star_half_mid_image_path
    #   starType : 'i'


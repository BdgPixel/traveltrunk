# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require blueimp-gallery
# = require blueimp-gallery-indicator
# = require jquery.lazyload
# = require bootstrap-datepicker
# = require google-api
# = require jquery.validate

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

loadMoreHotels = (cacheKey, cacheLocation, pageNumber) ->

  page = $(".deals-page[data-page='#{ pageNumber }']")

  if page.length > 0
    page.show()
    $('.deals-page').not(page).hide()
  else
    $('div.deals-image').removeClass 'lazy'
    url = "http://api.ean.com/ean-services/rs/hotel/v3/list?cid=#{ cid }&minorRev=28&apiKey=#{ apiKey }&locale=en_US&cacheKey=#{cacheKey}&cacheLocation=#{cacheLocation}&supplierType=E"

    $.ajax
      url: url
      type: 'GET'
      dataType: 'jsonp'
      beforeSend: ->
        $('#loading').show()
      success:  (data) ->
        $('#loading').fadeOut("slow")
        $('.deals-page').hide()

        previousPageNumber = $('.deals-page').length
        currentPageNumber =  previousPageNumber + 1
        nextPageNumber = currentPageNumber + 1

        # $('#dealsHotelsList .col-deals').remove()

        $('#loadMoreNext').attr('data-cache-key', data['HotelListResponse']['cacheKey'])
        $('#loadMoreNext').attr('data-cache-Location', data['HotelListResponse']['cacheLocation'])

        console.log data
        console.log window.teguh = data["HotelListResponse"]["EanWsError"]

        dealsPage = $("<div class='deals-page' data-page='#{ currentPageNumber }' >")
        $.each data["HotelListResponse"]["HotelList"]["HotelSummary"], (key, hotel) ->
          dealsWrapper = $('<div class="wrapper-price-deals">')
          dealsGrid = $('<div class="col-xs-6 col-md-4 col-deals">')
          dealsGrid.append $("<div class='price-deals'><strong>Nightly Price: $#{ hotel["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@averageRate"] }</strong></div>")
          dealsGrid.append $("<a href='/deals/#{ hotel['hotelId'] }/show' data-no-turbolink='true'><div class='lazy deals-image' data-original='#{ url_image }#{ hotel['thumbNailUrl'].replace('_t.', '_y.') }' style=\"background:url('#{ window.default_image_path }') no-repeat; background-size: 100% 100%; height: 300px;\"></div></a>")
          dealsGrid.append $("<div class='col-md-10'><p class='text-center content-deals'><a href='/deals/#{ hotel['hotelId'] }/show' data-toggle='tooltip' data-placement='top' data-title='#{ hotel['name'].toUpperCase() }' data-no-turbolink='true'>#{ hotel['name'].toUpperCase() }</a></p></div>")
          dealsGrid.append $("<div class='col-md-2'><div class='wrapper-like-deals'><p id='likeDeal' class='text-right content-deals'><a href='/deals/#{ hotel['hotelId'] }/like' data-remote='true'><span class='icon love-normal' id='like-#{ hotel['hotelId'] }'></span></a></p></div></div>")
          dealsWrapper.append dealsGrid
          dealsPage.append dealsWrapper

        dealsPage.append $("<div class='col-md-12'><div class='pull-right'><a class='btn btn-default loadMoreBack' data-previous-page='#{ previousPageNumber }'><i class='icon previous-loadmore pull-left'></i>&nbsp;&nbsp;Previous Page</a><a class='btn btn-default loadMoreNext' data-cache-key='#{ data['HotelListResponse']['cacheKey'] }' data-cache-Location='#{ data['HotelListResponse']['cacheLocation'] }' data-next-page='#{ nextPageNumber }' >Next Page<i class='icon next-loadmore'></i></a></div></div><br><br>")
        $('#dealsHotelsList').append dealsPage

        $('div.lazy').lazyload
          effect : 'fadeIn'

        $('[data-toggle="tooltip"]').tooltip()

        $(".loadMoreNext[data-next-page='#{ nextPageNumber }']").on 'click', ->
          loadMoreHotels($(this).attr('data-cache-key'), $(this).attr('data-cache-location'), $(this).data('next-page'))

        $(".loadMoreBack[data-previous-page='#{ previousPageNumber }']").on 'click', ->
          targetPageNumber = $(this).data('previous-page')
          targetPage = $(".deals-page[data-page='#{ targetPageNumber }']")
          console.log targetPage
          $('.deals-page').not(targetPage).hide()
          targetPage.show()

  return

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

      $('#destinationLabel').text $('#autocomplete').val().split(',')[0]

      dealsPage = $("<div class='deals-page' data-page='#{ currentPageNumber }' >")
      $.each data['HotelListResponse']['HotelList']['HotelSummary'], (key, hotel) ->
        dealsWrapper = $('<div class="wrapper-price-deals">')
        dealsGrid = $('<div class="col-xs-6 col-md-4 col-deals">')
        dealsGrid.append $("<div class='price-deals'><strong>Nightly Price: $#{ hotel["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@averageRate"] }</strong></div>")
        dealsGrid.append $("<a href='/deals/#{ hotel['hotelId'] }/show' data-no-turbolink='true'><div class='lazy deals-image' data-original='#{ url_image }#{ hotel['thumbNailUrl'].replace('_t.', '_y.') }' style=\"background:url('#{ window.default_image_path }') no-repeat; background-size: 100% 100%; height: 300px;\"></div></a>")
        dealsGrid.append $("<div class='col-md-10'><p class='text-center content-deals'><a href='/deals/#{ hotel['hotelId'] }/show' data-toggle='tooltip' data-placement='top' data-title='#{ hotel['name'].toUpperCase() }' data-no-turbolink='true'>#{ hotel['name'].toUpperCase() }</a></p></div>")
        dealsGrid.append $("<div class='col-md-2'><div class='wrapper-like-deals'><p id='likeDeal' class='text-right content-deals'><a href='/deals/#{ hotel['hotelId'] }/like' data-remote='true'><span class='icon love-normal' id='like-#{ hotel['hotelId'] }'></span></a></p></div></div>")
        dealsWrapper.append dealsGrid
        dealsPage.append dealsWrapper
        console.log dealsWrapper

      dealsPage.append $("<div class='col-md-12'><div class='pull-right'><a class='btn btn-default loadMoreNext' data-cache-key='#{ data['HotelListResponse']['cacheKey'] }' data-cache-Location='#{ data['HotelListResponse']['cacheLocation'] }' data-next-page='#{ nextPageNumber }' >Next Page<i class='icon next-loadmore'></i></a></div></div><br><br>")
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

      $('div.lazy').lazyload
        effect : 'fadeIn'

      $('#collapseDeals').slideToggle()
      $('[data-toggle="tooltip"]').tooltip()

      $(".loadMoreNext[data-next-page='#{ nextPageNumber }']").on 'click', ->
        loadMoreHotels($(this).attr('data-cache-key'), $(this).attr('data-cache-location'), $(this).data('next-page'))

  return

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
  disableEnterFormSubmit()
  validateSearchForm()

  # $('#destinationLabel').click ->
  #   $('#collapseDeals').slideToggle()

  #   return

  # if $('#galleria').length > 0
  #   Galleria.loadTheme window.galleria_theme_path
  #   Galleria.configure dummy: '/assets/default-no-image.png'
  #   Galleria.configure showInfo: false
  #   # Initialize Galleria
  #   Galleria.run '#galleria'

  if $('[data-toggle="tooltip"]').length > 0
    $('[data-toggle="tooltip"]').tooltip()

  if $('div.lazy').length > 0
    $('div.lazy').lazyload
      effect : 'fadeIn'

  if $('.loadMoreNext').length > 0
    $('.loadMoreNext').on 'click', -> loadMoreHotels($(this).attr('data-cache-key'), $(this).attr('data-cache-location'), $(this).attr('data-next-page'))

  if $('form#searchDealsForm').length > 0

    $('form#searchDealsForm').submit (e) ->
      searchDestination()
      e.preventDefault()

  if $('#btnClearText').length > 0
    $('#btnClearText').click ->
      $('input#autocomplete').val ''

      return

  if $('#links').length > 0
    blueimp.Gallery document.getElementById('links').getElementsByTagName('a'),
      container: '#blueimp-gallery-carousel'
      carousel: true

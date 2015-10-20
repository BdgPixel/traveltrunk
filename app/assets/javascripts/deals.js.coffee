# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require jquery.lazyload
# = require galleria
# = require bootstrap-datepicker
# = require holder
# = require google-api
# = require jquery.validate

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

loadMoreHotels = (cacheKey, cacheLocation) ->
  $('div.deals-image').removeClass 'lazy'
  url = "http://api.ean.com/ean-services/rs/hotel/v3/list?cid=#{ cid }&minorRev=28&apiKey=#{ apiKey }&locale=en_US&cacheKey=#{cacheKey}&cacheLocation=#{cacheLocation}&supplierType=E"

  $.ajax
    url: url
    type: 'GET'
    dataType: 'jsonp'
    beforeSend: ->
      $('#loading').show()
    success:  (data) ->
      $('#loading').fadeOut("slow");
      $('#dealsHotelsList .col-deals').remove()

      $('#loadMore').attr('data-cache-key', data['HotelListResponse']['cacheKey'])
      $('#loadMore').attr('data-cache-Location', data['HotelListResponse']['cacheLocation'])

      console.log data
      $.each data["HotelListResponse"]["HotelList"]["HotelSummary"], (key, hotel) ->
        dealsGrid = $('<div class="col-xs-6 col-md-4 col-deals">')
        dealsGrid.append $("<div class='text-left'><strong>Nightly Price: $#{ hotel["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@averageRate"] }</strong></div>")
        dealsGrid.append $("<a href='/deals/#{ hotel['hotelId'] }/show' data-no-turbolink='true'><div class='lazy deals-image' data-original='#{ url_image }#{ hotel['thumbNailUrl'].replace('_t.', '_y.') }' style=\"background:url('#{ window.default_image_path }') no-repeat; background-size: 100% 100%; height: 300px;\"></div></a>")
        dealsGrid.append $("<div class='col-md-10'><p class='text-center content-deals'><a href='/deals/#{ hotel['hotelId'] }/show' data-toggle='tooltip' data-placement='top' data-title='#{ hotel['name'] }' data-no-turbolink='true'>#{ hotel['name'].substring(0, 16) }</a></p></div>")
        dealsGrid.append $("<div class='col-md-2'><div class='wrapper-like-deals'><p id='likeDeal' class='text-right content-deals'><a href='/deals/#{ hotel['hotelId'] }/like' data-remote='true'><span class='icon love-normal' id='like-#{ hotel['hotelId'] }'></span></a></p></div></div>")

        $('#dealsHotelsList').append dealsGrid

      $('div.lazy').lazyload
        effect : 'fadeIn'

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
      console.log data
      $('#loadMore').show()
      $('#loadMore').attr('data-cache-key', data['HotelListResponse']['cacheKey'])
      $('#loadMore').attr('data-cache-Location', data['HotelListResponse']['cacheLocation'])
      $('#destinationLabel').text $('#autocomplete').val().split(',')[0]

      console.log window.hotel = data['HotelListResponse']['HotelList']['HotelSummary']
      $.each data['HotelListResponse']['HotelList']['HotelSummary'], (key, hotel) ->
        dealsGrid = $('<div class="col-xs-6 col-md-4 col-deals">')
        dealsGrid.append $("<div class='text-left'><strong>Nightly Price: $#{ hotel["RoomRateDetailsList"]["RoomRateDetails"]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@averageRate"] }</strong></div>")
        dealsGrid.append $("<a href='/deals/#{ hotel['hotelId'] }/show' data-no-turbolink='true'><div class='lazy deals-image' data-original='#{ url_image }#{ hotel['thumbNailUrl'].replace('_t.', '_y.') }' style=\"background:url('#{ window.default_image_path }') no-repeat; background-size: 100% 100%; height: 300px;\"></div></a>")
        dealsGrid.append $("<div class='col-md-10'><p class='text-center content-deals'><a href='/deals/#{ hotel['hotelId'] }/show' data-toggle='tooltip' data-placement='top' data-title='#{ hotel['name'] }' data-no-turbolink='true'>#{ hotel['name'].substring(0, 16) }</a></p></div>")
        dealsGrid.append $("<div class='col-md-2'><div class='wrapper-like-deals'><p id='likeDeal' class='text-right content-deals'><a href='/deals/#{ hotel['hotelId'] }/like' data-remote='true'><span class='icon love-normal' id='like-#{ hotel['hotelId'] }'></span></a></p></div></div>")

        $('#dealsHotelsList').append dealsGrid

      dateArrifal = new Date($('#search_deals_arrival_date').val())
      dateDeparture = new Date($('#search_deals_departure_date').val())
      arrivalDate = [dateArrifal.getFullYear(), dateArrifal.getMonth() + 1, dateArrifal.getDate()].join('/')
      departureDate = [dateDeparture.getFullYear(), dateDeparture.getMonth() + 1, dateDeparture.getDate()].join('/')

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

  return

$ ->
  $('input#search_deals_arrival_date').datepicker(
    startDate: today
    autoclose: true).on 'changeDate', (e) ->
      $('input#search_deals_departure_date').datepicker('remove')
      $('input#search_deals_departure_date').datepicker('setDate', $('input#search_deals_arrival_date').val())
      $('input#search_deals_departure_date').datepicker('show')
      $('input#search_deals_departure_date').datepicker
        startDate:  getFormattedDate(e.date)

  $('input#search_deals_departure_date').datepicker
    # startDate: today
    autoclose: true

  return

$(document).ready ->
  disableEnterFormSubmit()
  validateSearchForm()

  $('#destinationLabel').click ->
    $('#collapseDeals').slideToggle()

    return

  if $('#galleria').length > 0
    Galleria.loadTheme window.galleria_theme_path
    Galleria.configure dummy: '/assets/default-no-image.png'
    Galleria.configure showInfo: false
    # Initialize Galleria
    Galleria.run '#galleria'

  if $('[data-toggle="tooltip"]').length > 0
    $('[data-toggle="tooltip"]').tooltip()

  if $('div.lazy').length > 0
    $('div.lazy').lazyload
      effect : 'fadeIn'

  if $('#loadMore').length > 0
    $('#loadMore').on 'click', -> loadMoreHotels($('#loadMore').attr('data-cache-key'), $('#loadMore').attr('data-cache-location'))

  if $('form#searchDealsForm').length > 0

    $('form#searchDealsForm').submit (e) ->
      searchDestination()
      e.preventDefault()

  if $('#btnClearText').length > 0
    $('#btnClearText').click ->
      $('input#autocomplete').val ''

      return

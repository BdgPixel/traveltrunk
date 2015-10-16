# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require jquery.lazyload
# = require galleria
# = require bootstrap-datepicker
# = require holder
# = require google-api
# = require jquery.validate

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

$ ->
  $('input#search_deals_arrival_date').datepicker(
    startDate: today).on 'changeDate', (e) ->
      $('input#search_deals_departure_date').datepicker('remove')
      $('input#search_deals_departure_date').datepicker(
        startDate:  getFormattedDate(e.date))

  $('input#search_deals_departure_date').datepicker startDate: today

  return

loadMoreHotels = (cacheKey, cacheLocation) ->
  $('div.deals-image').removeClass 'lazy'
  url = "http://api.ean.com/ean-services/rs/hotel/v3/list?cid=55505&minorRev=28&apiKey=5fd6485clmp3oogs8gfb43p2uf&locale=en_US&cacheKey=#{cacheKey}&cacheLocation=#{cacheLocation}&supplierType=E"
  url_image = "http://images.travelnow.com"
  tags = ""

  $.ajax
    url: url
    type: 'GET'
    dataType: 'jsonp'
    beforeSend: ->
      $('#loading').show()
    success:  (data) ->
      $('#loading').fadeOut("slow");

      $.each data["HotelListResponse"]["HotelList"]["HotelSummary"], (key, hotel) ->
        # console.log hotel["thumbNailUrl"]
        dealsGrid = $('<div class="col-xs-6 col-md-4 col-deals">')
        dealsGrid.append $("<div class='lazy deals-image' data-original='#{url_image}#{hotel['thumbNailUrl'].replace('_t.', '_y.')}' style=\"background:url('#{window.default_image_path}') no-repeat; background-size: 100% 100%; height: 300px;\">")
        dealsGrid.append $("<div class='col-md-10'><p class='text-center content-deals'><a href='/deals/#{(hotel['hotelId'])}' data-toggle='tooltip' data-placement='top' data-title='#{hotel['name']}' data-no-turbolink='true'>#{hotel['name'].substring(0, 16)}</a></p><p class='text-center'><strong>Hight Rate: $#{hotel["highRate"]}</strong>&nbsp;<strong>Low Rate: $#{hotel["lowRate"]}</strong></p></div>")
        dealsGrid.append $("<div class='col-md-2'><p id='likeDeal' class='text-right content-deals'><a href='/deals/#{hotel['hotelId']}like'><span class='glyphicon glyphicon-heart-empty' style='font-size: 38px' id='like-#{hotel['hotelId']}'></span></a></p></div>")


        $('#dealsHotelsList').append dealsGrid
        # tags = $('#dealsHotelsList').append '<div class="col-xs-6.col-md-4.col-deals">'
        # tags += "<div class='deals-image' data-original='#{url_image}#{hotel['thumbNailUrl']}.replace('_t.', '_y.')'> "

      $('div.lazy').lazyload
        effect : 'fadeIn'

  return

$(document).ready ->
  disableEnterFormSubmit()
  validateSearchForm()

  $('#destinationLabel').click ->
    $('#collapseDeals').slideToggle()

  if $('#galleria').length > 0
    Galleria.loadTheme window.galleria_theme_path
    Galleria.configure dummy: '/assets/default-no-image.png'
    # Initialize Galleria
    Galleria.run '#galleria'

  if $('[data-toggle="tooltip"]').length > 0
    $('[data-toggle="tooltip"]').tooltip()

  if $('div.lazy').length > 0
    $('div.lazy').lazyload
      effect : 'fadeIn'

  if $('#loadMore').length > 0
    $('#loadMore').on 'click', -> loadMoreHotels($('#loadMore').data('cache-key'), $('#loadMore').data('cache-location'))

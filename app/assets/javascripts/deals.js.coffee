# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require blueimp-gallery
# = require blueimp-gallery-indicator
# = require jquery.lazyload
# = require bootstrap-datepicker
# = require google-api
# = require jquery.simplePagination
# = require jquery.raty
# = require ratyrate
# = require savings_form_validation
# = require autoNumeric-min

root = exports ? this

getFormattedDate = (date) ->
  day = date.getDate()
  month = date.getMonth() + 1
  year = date.getFullYear()
  formattedDate = [month, day, year].join('/')

  formattedDate

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

validateFormBook = ->
  if $('#formBook').length > 0
    $('#formBook').on 'submit', (e) ->
      returnValue = undefined
      returnValue = undefined
      returnValue = null

      if $('#confirmation_book_policy').is(':checked') == false
        $('.payment-errors').html 'Cancellation policy must be approved'
        returnValue = false
      returnValue

root.initDealsPage = (numOfpages, numOfHotels)->
  if numOfpages && numOfHotels && numOfHotels > 15
    $('#pagination')
      .pagination
        pages: numOfpages
        cssStyle: 'light-theme'
        displayedPages: 3
        edges: 1
        onPageClick: (pageNumber, event)->
          selectedPage = $("#page-#{pageNumber}")
          selectedPage.show()
          $(".deal-pages").not(selectedPage).hide()
          $('html, body').animate { scrollTop: 0 }, 'slow'

          prevPage = pageNumber - 1
          startRange = (prevPage * 15) + 1
          endRange = pageNumber * 15
          endRange = numOfHotels if endRange > numOfHotels
          $("p#pagination-info").text(startRange + " - " + endRange + ' of ' + numOfHotels + " Hotels")

          false

  $('div.lazy').lazyload()

listOfMonts = (month) ->
  months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  months[month]

root.roomSelected = (selector)->
  $(selector).on 'click', ->
    rateCode = $(this).data('rate-code')
    roomTypeCode = $(this).data('room-type-code')
    numberOfRoomsRequested = rooms.numberOfRoomsRequested

    $('.bs-example-modal-lg').modal({ backdrop: 'static' })
    $('.modal .modal-header h3').text(rooms.hotelName)
    $('.modal #roomRating').attr('data-rating', rooms.tripAdvisorRating)

    if rooms.tripAdvisorRating
      $('.modal .rating-text').text(rooms.tripAdvisorRating + " ratings")
    else
      $('.modal .rating-text').text("0 rating")

    $('.modal .hotel-info-addr').html("&nbsp;#{rooms.hotelAddress}")
    $('.modal .hotel-info-city').html("&nbsp;City:&nbsp; #{rooms.hotelCity}")

    if rooms.hotelStateProvince
      $('.modal .hotel-info-state').html("&nbsp;State:&nbsp; #{rooms.hotelStateProvince}")
    else
      $('.modal .hotel-info-state').html("&nbsp;State:&nbsp; Information not specified")

    $('.modal .hotel-info-country').html("&nbsp;Country:&nbsp; #{rooms.hotelCountry}")
    $('.modal .checkin-intructions').html(rooms.checkInInstructions)

    $('#confirmation_book_hotel_id').val($(this).data('id'))
    $('#confirmation_book_arrival_date').val(rooms.arrivalDate)
    $('#confirmation_book_departure_date').val(rooms.departureDate)
    $('#confirmation_book_rate_code').val(rateCode)
    $('#confirmation_book_room_type_code').val(roomTypeCode)

    room = null

    if rooms['@size'] is '1'
      room = [rooms.HotelRoomResponse]
    else
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

    $('.modal #roomName').html(room[0]["rateDescription"])

    listOfDate  = ''
    nightlyRate = ''

    $.each dates, (key, date) ->
      month = listOfMonts(date.getMonth())
      if room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['NightlyRatesPerRoom']['@size'] == ('1')
        table.append("<tr><td>#{month} #{date.getDate()}, #{date.getFullYear()}</td><td>#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['NightlyRatesPerRoom']['NightlyRate']['@baseRate']}</td></tr>")
      else
        listOfDate = "<tr><td>#{month} #{date.getDate()}, #{date.getFullYear()}</td>"
        $.each room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['NightlyRatesPerRoom']['NightlyRate'], (keyRate, rate) ->
          if key == keyRate
            nightlyRate = "<td>$#{rate['@rate']}</td></tr>"
            table.append(listOfDate + nightlyRate)

    table.append("<tr><td><b>Total taxes and fees</b></td><td>$#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@surchargeTotal']}</td></td>")
    table.append("<tr><td><b>Total Charges</b><br><small><i>(includes tax recovery charges and service fees)</i></small></td><td>$#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@total']}</td></tr>")

    taxs = room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']

    if taxs["Surcharges"] && parseInt(taxs["Surcharges"]["@size"]) > 1
      $.each taxs["Surcharges"]["Surcharge"], (key, tax) ->
        unless tax["@type"] is "TaxAndServiceFee"
          table.append("<tr><td><b>#{tax['@type']}</b></td><td>$#{tax['@amount']}</td></tr>")

    $('#confirmation_book_total').val(room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@total'])
    $('#confirmation_book_rate_key').val(room[0]['RateInfos']['RateInfo']['RoomGroup']['Room']['rateKey'])

    if room[0]['RoomImages']
      if room[0]["RoomImages"]["@size"] == ("1")
        $('#roomImage').attr('src', room[0]['RoomImages']['RoomImage']['url'])
      else
        $('#roomImage').attr('src', room[0]['RoomImages']['RoomImage'][0]['url'])
      $('#imageDisclaimer').hide()
    else
      $('#roomImage').attr('src', 'http://media.expedia.com/hotels/1000000/50000/40400/40338/40338_208_s.jpg')
      $('#imageDisclaimer').show()


    if room[0]['BedTypes']['@size'] == '1'
      $('#confirmation_book_bed_type').val(room[0]['BedTypes']['BedType']['@id'])
    else
      $('#confirmation_book_bed_type').val $.map(room[0]['BedTypes']['BedType'], (b) ->
        b['@id']
      )

    if $('#roomRating').length > 0
      rating_count = parseFloat($('#roomRating').attr('data-rating'))

      $('#roomRating').raty
        half: true
        readOnly: true
        size: 24
        score: rating_count
        starOn: window.star_on_mid_image_path
        starOff: window.star_off_mid_image_path
        starHalf: window.star_half_mid_image_path

appendCreditform = ->
  $('.append-credit').on 'click', ->
    rateCode = $(this).data('rate-code')
    $(this).addClass("form-#{rateCode}")
    $('#update_credit_rate_code').val(rateCode)
    $('#update_credit_total').val($(this).data('total'))

root.replaceImage = ->
  sliderImages = $('a.slider-images')

  i = 0
  while i < sliderImages.length
    previousSrc = $(sliderImages[i]).attr('href')
    image = new Image()

    image.onerror = ()->
      console.error("Cannot load image")
      src = $(this).attr('src');
      targetElement = $("a.slider-images[href='#{src}']")

      newSrc = null

      if src.split('_')[2] is 'z.jpg'
        newSrc = src.replace('_z.jpg', '_y.jpg')
      else if src.split('_')[2] is 'y.jpg'
        newSrc = src.replace('_y.jpg', '_b.jpg')

      $(targetElement).attr('href', newSrc)

    image.src = previousSrc

    i++

root.popOver = (selector)->
  $(selector).on 'click', ->
    $(this).popover 'show'
    return


$(document).ready ->
  if window.location.pathname == '/' or window.location.pathname == '/deals' or window.location.pathname == '/deals/'
    disableEnterFormSubmit()
    validateSearchForm()
    $.get '/deals'

    today = getFormattedDate(new Date)

    $('input#search_deals_arrival_date').datepicker(
      startDate: today
      autoclose: true).on 'changeDate', (e) ->
        departureDate = e.date
        departureDate.setDate(departureDate.getDate() + 1)

        $('input#search_deals_departure_date').datepicker('remove')
        $('input#search_deals_departure_date').datepicker
          startDate:  getFormattedDate(departureDate)
          autoclose: true
        setTimeout(->
          $('input#search_deals_departure_date').datepicker('show')
        , 100)

    $('input#search_deals_departure_date').datepicker
      startDate: today
      autoclose: true


    if $('#slideToggleLink').length > 0
      $('#slideToggleLink').on 'click', (e) ->
        $('#slideToggle').slideToggle()
        return

      $('.slide').on 'click', (e) ->
        if e.target != this
          return
        $('#slideToggle').slideUp()
        return

      $('.text-header-slide').on 'click', (e) ->
        if e.target != this
          return
        $('#slideToggle').slideUp()
        return

    if $('#btnClearText').length > 0
      $('#btnClearText').click ->
        $('input#autocomplete').val ''

        return

  else
    initAutoNumeric('#update_credit_formatted_amount', '#update_credit_amount')
    params_path_id = window.location.pathname.split('/')[2]
    validateFormBook()

    $.get "/deals/#{ params_path_id }/room_availability", ->
      roomSelected('.room-selected')
      appendCreditform()

      $('#modalSavingsForm').on 'hidden.bs.modal', (e) ->
        $('#formAddToSavings').get(0).reset()
        $('.payment-errors').html("")

      $('.modal-lg').on 'hidden.bs.modal', (e) ->
        $('#formBook').get(0).reset()

      return

    if $('#hotelRating').length > 0
      rating_count = parseFloat($('#hotelRating').data('rating'))

      $('#hotelRating').raty
        half: true
        readOnly: true
        size: 24
        score: rating_count
        starOn: window.star_on_mid_image_path
        starOff: window.star_off_mid_image_path
        starHalf: window.star_half_mid_image_path

    if $('#links').length > 0
      replaceImage() # replace biggest image if not found, with medium image

      setTimeout( ->
        replaceImage() # replace medium image if not found, with small image
      , 1000)

      setTimeout( ->
        blueimp.Gallery $('.slider-images'),
          container: '#blueimp-gallery-carousel'
          carousel: true
      , 3000)

    # $(document).on 'click', '[data-toggle="popover"]', ->
    #   $(document).find('[data-toggle="popover"]').popover('hide')
    #   $(this).popover 'show'
    #   return





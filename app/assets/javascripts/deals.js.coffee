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
# = require moment
# = require moment-timezone

root = exports ? this

replaceImageInterval = undefined
imageSizeType = null
imageLoadedCount = 0

getFormattedDate = (date) ->
  day = date.getDate()
  month = date.getMonth() + 1
  year = date.getFullYear()
  formattedDate = [month, day, year].join('/')

  formattedDate

validateSearchForm = ->
  $('#searchDealsForm').validate
    ignore: ".ignore"
    rules:
      autocomplete: 'required'

    messages:
      autocomplete: 'Please enter your destination'

  return

root.validateFormBook = ->
  if $('#formBook').length > 0
    $('#formBook').on 'submit', (e) ->
      returnValue = undefined
      returnValue = undefined
      returnValue = null

      $('.payment-errors').text('')

      if $('#confirmation_book_bed_type option:first').is(':selected') == true
        $('.errors-bed-type').html 'Please select one of bed type'
        returnValue = false
      else if $('#confirmation_book_policy').is(':checked') == false
        $('.errors-policy').html 'Cancellation policy must be approved'
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
    $('.payment-errors').text('')
    $('#confirmation_book_policy').removeAttr('checked');
    rateCode = $(this).data('rate-code')
    roomTypeCode = $(this).data('room-type-code')
    numberOfRoomsRequested = rooms.numberOfRoomsRequested

    $('#modalBook').modal('show')
    $('.modal .modal-header h3').not('#myModalLabel').text(rooms.hotelName)
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

    if rooms.specialCheckInInstructions
      $('.modal .special-checkin-instructions').html(rooms.specialCheckInInstructions)
      
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

    numberOfChildren = room[0]['RateInfos']['RateInfo']['RoomGroup']['Room']['numberOfChildren']
    childAge = room[0]['RateInfos']['RateInfo']['RoomGroup']['Room']['childAges']

    if parseInt(numberOfChildren) > 1
      $('.modal #childAndAge').html "Children: #{numberOfChildren}, Child Age(s): #{childAge}"

    listOfDate  = ''
    nightlyRate = ''

    $.each dates, (key, date) ->
      month = listOfMonts(date.getMonth())

      if room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['NightlyRatesPerRoom']['@size'] == ('1')
        table.append("<tr><td>#{month} #{date.getDate()}, #{date.getFullYear()}</td><td>$#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['NightlyRatesPerRoom']['NightlyRate']['@rate']}</td></tr>")
      else
        listOfDate = "<tr><td>#{month} #{date.getDate()}, #{date.getFullYear()}</td>"
        $.each room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['NightlyRatesPerRoom']['NightlyRate'], (keyRate, rate) ->
          if key == keyRate
            nightlyRate = "<td>$#{rate['@rate']}</td></tr>"
            table.append(listOfDate + nightlyRate)

    taxs = room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']

    if taxs["Surcharges"] && parseInt(taxs["Surcharges"]["@size"]) > 1
      $.each taxs["Surcharges"]["Surcharge"], (key, tax) ->
        if tax["@type"] is "SalesTax"
          table.append("<tr>
            <td>
              <b>Sales Tax</b>
              <small><i>(already included in total price)</i></small>
            </td>
            <td>$#{tax['@amount']}</td>
          </tr>")
        else
          table.append("<tr>
            <td>
              <b>Tax and Service Fee</b>
            </td>
            <td>$#{tax['@amount']}</td>
          </tr>")

    hotelFees = room[0]['RateInfos']['RateInfo']['HotelFees']
    hotelFeeTag = ''

    if hotelFees
      if parseInt(hotelFees['@size']) > 1
        $.each hotelFees['HotelFee'], (key, hotelFee) ->
          hotelFeeTag += "<p class='mandatory-tax'>+#{hotelFee['@amount']} due at hotel</p>"
          return
      else
        hotelFeeTag = "<p class='mandatory-tax'>+#{hotelFees['HotelFee']['@amount']} due at hotel</p>"

    # table.append("<tr><td><b>Total Taxes and Fees</b></td><td>$#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@surchargeTotal']}</td></td>")
    table.append("<tr><td><b>Total Charges</b><br><small><i>(includes tax recovery charges and service fees)</i></small></td><td class='total-charges-text' dom='total_charges_text'><h4>$#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@total']}</h4>#{hotelFeeTag}</td></tr>")

    $('#confirmation_book_total').val(room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@total'])
    $('#confirmation_book_rate_key').val(room[0]['RateInfos']['RateInfo']['RoomGroup']['Room']['rateKey'])
    $('#confirmation_book_smoking_preferences').val(room[0]['smokingPreferences'])
    $('.modal .cancellation-policy').html(room[0]['RateInfos']['RateInfo']['cancellationPolicy'])

    if $(this).data('group')
      $('.form-book').hide()
      $('#linkVote').attr('href', "/deals/#{rooms.hotelId}/like?hotel_name=#{rooms.hotelName}")
      $('.form-vote ').show()

    existingRoomImage = $(this).closest('tr').find('.room-image')

    if existingRoomImage
      $('#roomImage').attr('src', existingRoomImage.attr('src'))

      if $(this).closest('tr').find('small.image-disclaimer').length is 0
        $('#imageDisclaimer').hide()
      else
        $('#imageDisclaimer').show()
    else
      if room[0]['RoomImages']
        if room[0]["RoomImages"]["@size"] == ("1")
          $('#roomImage').attr('src', room[0]['RoomImages']['RoomImage']['url'].replace('http', 'https'))
        else
          $('#roomImage').attr('src', room[0]['RoomImages']['RoomImage'][0]['url'].replace('http', 'https'))
        $('#imageDisclaimer').hide()
      else
        $('#roomImage').attr('src', 'https://media.expedia.com/hotels/1000000/50000/40400/40338/40338_208_s.jpg')
        $('#imageDisclaimer').show()

    $('#confirmation_book_bed_type option').not(':first').remove()

    if room[0]['BedTypes']['@size'] == '1'
      # $('#confirmation_book_bed_type').val(room[0]['BedTypes']['BedType']['@id'])
      $('#confirmation_book_bed_type').append new Option(room[0]['BedTypes']['BedType']['description'], room[0]['BedTypes']['BedType']['@id'])    
      $('#confirmation_book_bed_type option:last').prop 'selected', true
    else
      # $('#confirmation_book_bed_type').val $.map(room[0]['BedTypes']['BedType'], (b) ->
      #   b['@id']
      # )
      $.each room[0]['BedTypes']['BedType'], (index, item) ->
        $('#confirmation_book_bed_type').append new Option(item['description'], item['@id'])
        return

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

checkImage = (previousSrc, numberOfImages, i)->
  image = new Image()

  image.onload = ()->
    imageLoadedCount += 1

  image.onerror = ()->
    src = $(this).attr('src');
    targetElement = $("a.slider-images[href='#{src}']")

    newSrc = null
    extension = src.split('_').slice(-1)[0]

    if extension is 'z.jpg'
      newSrc = src.replace('_z.jpg', '_y.jpg')
      imageSizeType = 'y'
    else if extension is 'y.jpg'
      newSrc = src.replace('_y.jpg', '_b.jpg')
      imageSizeType = 'b'

    $(targetElement).attr('href', newSrc)

    if imageSizeType != 'b'
      checkImage(newSrc, numberOfImages, i)
    else
      newImage = new Image()

      newImage.onload = ()->
        imageLoadedCount += 1

      newImage.src = newSrc

  image.src = previousSrc

root.replaceImage = ()->
  sliderImages = $('a.slider-images')
  numberOfImages = sliderImages.length

  i = 0
  while i < numberOfImages
    previousSrc = $(sliderImages[i]).attr('href')
    checkImage(previousSrc, numberOfImages, i)

    i++

root.popOver = (selectorLink, selectorTitle = null, selectorContent, trigger, placement) ->
  $(selectorLink).popover
    html: true
    placement: placement
    trigger: trigger
    content: ->
      $(selectorContent).html()
    title: ->
      if selectorTitle
        $(selectorTitle).html()
      else
        false

appendValueRoomParams = () ->
  $('#create_credit_arrival_date').val($('#confirmation_book_arrival_date').val())
  $('#create_credit_departure_date').val($('#confirmation_book_departure_date').val())
  $('#create_credit_rate_code_room').val($('#confirmation_book_rate_code').val())
  $('#create_credit_room_type_code').val($('#confirmation_book_room_type_code').val())
  $('#create_credit_rate_key').val($('#confirmation_book_rate_key').val())
  $('#create_credit_total_charge').val($('#confirmation_book_total').val())
  $('#create_credit_bed_type').val($('#confirmation_book_bed_type').val())
  $('#create_credit_smoking_preferences').val($('#confirmation_book_smoking_preferences').val())

ready  = ->
  controller = $('body').data('controller')
  action = $('body').data('action')

  # if window.location.pathname == '/' or window.location.pathname == '/deals' or window.location.pathname == '/deals/'
  if controller == 'deals' && action == 'index'
    disableEnterFormSubmit()

    validateSearchForm()

    $.ajax
      url: '/deals.js'
      cache: false
      timeout: 30000

    moment.tz.add('America/Los_Angeles|PST PDT|80 70|01010101010|1Lzm0 1zb0 Op0 1zb0 Rd0 1zb0 Op0 1zb0 Op0 1zb0');
    moment.tz.link('America/Los_Angeles|US/Pacific')
    today = moment.tz('US/Pacific').format('M/D/Y')

    $('input#search_deals_arrival_date').datepicker(
      startDate: today
      autoclose: true).on 'changeDate', (e) ->
        $(this).valid()
        departureDate = e.date
        departureDate.setDate(departureDate.getDate() + 1)

        $('input#search_deals_departure_date').datepicker('remove')
        $('input#search_deals_departure_date').datepicker
          startDate:  getFormattedDate(departureDate)
          autoclose: true
        setTimeout(->
          $('input#search_deals_departure_date').datepicker('show')
        , 100)

    $('input#search_deals_departure_date').datepicker(
      startDate: today
      autoclose: true).on 'changeDate', (e) ->
        $(this).valid()

    showSearchForm()

    if $('#btnClearText').length > 0
      clearSearchText '#btnClearText', 'input#autocomplete'

    showPopUpProfile()

  else if controller == 'deals' && action == 'show'
    initAutoNumeric('.formatted-amount', '.amount')

    params_path_id = window.location.pathname.split('/')[2]

    validateFormBook()

    popOver('#linkPopover', '#titlePopover', '#contentPopover', 'click', 'top')

    $(document).on 'click', '[data-dismiss="popover"]', (e) ->
      $(this).closest('div').prev().popover('hide')

    $('body').on 'hidden.bs.popover', (e) ->
      $(e.target).data("bs.popover").inState = { click: false, hover: false, focus: false }
    
    $.ajax
      url: "/deals/#{ params_path_id }/room_availability.js"
      cache: false
      timeout: 30000
      success: (data, textStatus, jqXHR) ->
        roomSelected('.room-selected')
        appendCreditform()

        $('#modalSavingsForm').on 'hidden.bs.modal', (e) ->
          $('#formAddToSavings').get(0).reset()
          $('.payment-errors').html("")

        $('.modal-lg').on 'hidden.bs.modal', (e) ->
          $('#formBook').get(0).reset()
          $('.form-book').show()
          $('.payment-errors').html("")
          # removeBackdropModal '#modalBook'

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

      replaceImageInterval = setInterval(->
        if (imageLoadedCount == $('.slider-images').length) || imageSizeType == 'b'
          clearInterval replaceImageInterval

          setTimeout( ->
            blueimp.Gallery $('.slider-images'),
            container: '#blueimp-gallery-carousel'
            carousel: true
          , 2000)
      , 1000)

    $('#linkBtnYes').on 'click', ->
      $('.payment-errors').text('')

      if $('#confirmation_book_bed_type option:first').is(':selected') == true
        $('.errors-bed-type').html 'Please select one of bed type'
      else if $('#confirmation_book_policy').is(':checked') == false
        $('.errors-policy').html 'Cancellation policy must be approved'
      else
        # removeBackdropModal '#modalBook'
        $('#confirmation_book_policy').removeAttr('checked');
        $('.payment-errors').text('')
        $('#modalBook').modal 'hide'

        root.modalDialog = $(this).parents('.modal').find('.modal-dialog')
        modalDialog.modal 'hide'

        $('#modalSavingsForm').modal 'show'
        $('#modalSavingsForm').on 'shown.bs.modal', (e) ->
          $('#modalSavingsForm').css('overflow-x', 'hidden')
          $('#modalSavingsForm').css('overflow-y', 'auto')

        totalCharges = $('[dom="total_charges_text"]').text().replace('$', '')
        $('#totalCharges').attr('data-total-charges', totalCharges)
        appendValueRoomParams()
        $('#modalSavingsForm .modal-header > h3').text $('#roomName').text()
        $('.amount').val parseFloat($('#totalCharges').data('total-charges'))

      return

$(document).ready -> ready()
$(document).on 'page:load', -> ready()
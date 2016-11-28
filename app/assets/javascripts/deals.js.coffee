# = require jquery.flipster
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
    else if rooms.tripAdvisorRating == undefined
      $('.modal .rating-text').text($('.rating-text').first().text())
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

    getSurcharge room[0], table, europeCountries, rooms['hotelCountry']
    hotelFees = room[0]['RateInfos']['RateInfo']['HotelFees']
    hotelFeeTag = ''

    if hotelFees
      if parseInt(hotelFees['@size']) > 1
        $.each hotelFees['HotelFee'], (key, hotelFee) ->
          feeDescription = hotelFee['@description'].split(/(?=[A-Z])/).join(" ")
          hotelFeeTag += "<p class='mandatory-tax'>+#{hotelFee['@amount']} due at hotel (#{feeDescription})</p>"
          return
      else
        feeDescription = hotelFees['HotelFee']['@description'].split(/(?=[A-Z])/).join(" ")
        hotelFeeTag = "<p class='mandatory-tax'>+#{hotelFees['HotelFee']['@amount']} due at hotel (#{feeDescription})</p>"

    # table.append("<tr><td><b>Total Taxes and Fees</b></td><td>$#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@surchargeTotal']}</td></td>")
    table.append("<tr><td><b>Total Charges</b><br><small><i>(includes tax recovery charges and service fees)</i></small></td><td class='total-charges-text' dom='total_charges_text'><h4>$#{room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@total']}</h4>#{hotelFeeTag}</td></tr>")

    $('#confirmation_book_total').val(room[0]['RateInfos']['RateInfo']['ChargeableRateInfo']['@total'])
    $('#confirmation_book_rate_key').val(room[0]['RateInfos']['RateInfo']['RoomGroup']['Room']['rateKey'])
    $('#confirmation_book_smoking_preferences').val(room[0]['smokingPreferences'])
    $('.modal .cancellation-policy').html(room[0]['RateInfos']['RateInfo']['cancellationPolicy'])
    
    membersVoted($(this).data('is-group'), this, rooms.hotelName, room)
    allowBooking($(this).data('is-group'), this, rooms.hotelId, room)

    existingRoomImage = $(this).closest('div.wrapper-body-room').find('.room-image')

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
    getBedType room[0]

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

membersVoted = (isGroup, thisGroup, hotelName, room) ->
  if isGroup
    $('.form-book').hide()
    $('#agree:checked').removeAttr('checked')
    $('#linkVote').attr('disabled', true)
    $('#linkVote').attr('href', 'javascript:void(0)')

    $('#agreeTermCondition').addClass('hide')
    $('#linkVote').removeAttr('disabled')

    $('.vote-hotel-name').val(hotelName)
    $('.vote-share-image').val($('#shareHotelInfo').data('share-image'))
    $('.vote-rate-code').val(room[0]['rateCode'])
    $('.vote-room-type-code').val(room[0]['RoomType']['@roomCode'])

    if $(thisGroup).data('cancel-vote')
      $('#voteConfirmationText').text('Would you like to cancel vote to this hotel?')
      $('form.like').data('remote', false)
    else
      $('#voteConfirmationText').text('Would you like to agree to this hotel?')
      $('form.like').data('remote', true)

    $('.form-vote ').show()

allowBooking = (isGroup, thisGroup, hotelId, room) ->
  if isGroup
    if $(thisGroup).data('allow-booking') != undefined
      $('.form-book').show()
      $('.form-vote').hide()

      membersVotedStr = $(thisGroup).siblings('.members-voted').text().trim()
      totalGroupCredit = parseFloat($(thisGroup).data('total-group-credit'))
      totalRoom = parseFloat($(thisGroup).data('total'))

      if totalGroupCredit < totalRoom
        initAddToSavingForm(totalGroupCredit, totalRoom, hotelId, room, $(thisGroup).data('members-count'))
      else
        $("form#formBook input[type='submit']").val('Book Now')

      if membersVotedStr.length > 0
        $('#modalMembersVoted').removeClass('hide')
      else
        $('#modalMembersVoted').addClass('hide')

      if $(thisGroup).data('allow-booking') == true
        $('#modalMembersVoted p').text(membersVotedStr)
        $("form#formBook input[type='submit']").removeAttr('disabled')
        $('#agree').removeAttr('disabled')
      else
        root.thisGroup = thisGroup

        initAddToSavingForm(totalGroupCredit, totalRoom, hotelId, room, $(thisGroup).data('members-count'))

        $('#agree').attr('disabled', 'disabled')

        if membersVotedStr.length > 0
          $('#modalMembersVoted p').text(membersVotedStr + ' (all members need to agree on this hotel first, before you can book)')
        else
          $('#modalMembersVoted').removeClass('hide')
          $('#modalMembersVoted p').text('All members need to agree on this hotel first, before you can book')
          
        $("form#formBook input[type='submit']").attr('disabled', 'disabled')

initAddToSavingForm = (totalGroupCredit, totalRoom, hotelId, room, membersCount) ->
  linkModalAddToSavingForm = $('#linkModalAddToSavingForm')

  if totalGroupCredit < totalRoom
    $("form#formBook input[type='submit']").addClass('hide')
    $("form.like input[type='submit']").addClass('hide')
    $("#jsBedTypeSection").addClass('hide')
    $("#jsTermsConditionsSection").addClass('hide')
    linkModalAddToSavingForm.removeClass('hide')

    linkModalAddToSavingForm.attr
      # 'data-toggle': "modal"
      # 'data-target': "#modalSavingsForm"
      'data-id': hotelId
      'data-rate-code': room[0]['rateCode']
      'data-room-type_code': room[0]["RoomType"]["@roomCode"]
      'data-total': room[0]["RateInfos"]["RateInfo"]["ChargeableRateInfo"]["@total"]

    linkModalAddToSavingForm.on 'click', ->
      $('#modalSavingsForm').modal('show')

    $('#modalSavingsForm').on 'show.bs.modal', ->
      $('#modalBook').modal 'hide'

      # add routes query string
      $('#formAddToSavings').attr('action', '/deals/update_credit?is_referrer=true')

      creditGroup = ((totalRoom - totalGroupCredit) / parseInt(membersCount)).toFixed(2)
      $('#modalSavingsForm .modal-header small').remove()
      $('#groupCreditText').text("Your minimum contribution for this hotel is $#{creditGroup}")
      $('#formAddToSavings').attr('data-is-referrer', true)
  else
    $("form#formBook input[type='submit']").removeClass('hide')
    $("form.like input[type='submit']").removeClass('hide')
    $("#jsBedTypeSection").removeClass('hide')
    $("#jsTermsConditionsSection").removeClass('hide')
    linkModalAddToSavingForm.addClass('hide')

showHideComponents = ->


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
        selectorTitle + '<span class="close popover-close">&times;</span>';
      else
        '<span class="close popover-close">&times;</span>';

listOfMonts = (month) ->
  months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  months[month]

getBedType = (room) ->
  bedTypes = room['BedTypes']

  if bedTypes
    if bedTypes['@size'] == '1'
      # $('#confirmation_book_bed_type').val(room[0]['BedTypes']['BedType']['@id'])
      $('.bed-type').text("Bed type: #{bedTypes['BedType']['description']}")
      $('#confirmation_book_bed_type').append new Option(bedTypes['BedType']['description'], bedTypes['BedType']['@id'])
      $('#confirmation_book_bed_type option:last').prop 'selected', true
      $('#confirmation_book_bed_type').hide()
    else
      # $('#confirmation_book_bed_type').val $.map(room[0]['BedTypes']['BedType'], (b) ->
      #   b['@id']
      # )
      $('.bed-type').text 'Bed type'
      $.each bedTypes['BedType'], (index, item) ->
        $('#confirmation_book_bed_type').append new Option(item['description'], item['@id'])
        $('#confirmation_book_bed_type').show()
        return
  else
    description = room['roomTypeDescription'] || room['rateDescription']

    $('.bed-type').text("Bed type: #{description}")
    $('#confirmation_book_bed_type').append new Option(description, null)
    $('#confirmation_book_bed_type option:last').prop 'selected', true
    $('#confirmation_book_bed_type').hide()

getSurcharge = (room, table, europeCountries, hotelCountry) ->
  root.taxs = room['RateInfos']['RateInfo']['ChargeableRateInfo']['Surcharges']
  root.europeCountries
  labelTax = ''

  if $.inArray(hotelCountry, europeCountries) > -1
    labelTax = 'Tax Recovery Charges'
  else
    labelTax = 'Tax Recovery Charges and Service Fees'

  if taxs && parseInt(taxs["@size"]) > 1
    $.each taxs["Surcharge"], (key, tax) ->
      if tax["@type"] is "SalesTax"
        table.append("<tr>
          <td>
            <b>Sales Tax</b>
            <small><i>(already included in total price)</i></small>
          </td>
          <td>$#{tax['@amount']}</td>
        </tr>")

      if tax["@type"] is "TaxAndServiceFee"
        if $.inArray(hotelCountry, europeCountries)
          table.append("<tr>
            <td>
              <b>#{labelTax}</b>
            </td>
            <td>$#{tax['@amount']}</td>
          </tr>")
        else
  else
    table.append("<tr>
      <td>
        <b>#{labelTax}</b>
      </td>
      <td>$#{taxs['Surcharge']['@amount']}</td>
    </tr>")

appendCreditform = ->
  $('.append-credit').on 'click', ->
    rateCode = $(this).data('rate-code')
    $(this).addClass("form-#{rateCode}")
    $('#update_credit_rate_code').val(rateCode)
    $('#update_credit_total').val($(this).data('total'))

    clearValidationMessage()

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

appendValueRoomParams = () ->
  $('#guest_booking_arrival_date').val($('#confirmation_book_arrival_date').val())
  $('#guest_booking_departure_date').val($('#confirmation_book_departure_date').val())
  $('#guest_booking_rate_code_room').val($('#confirmation_book_rate_code').val())
  $('#guest_booking_room_type_code').val($('#confirmation_book_room_type_code').val())
  $('#guest_booking_rate_key').val($('#confirmation_book_rate_key').val())
  $('#guest_booking_total_charge').val($('#confirmation_book_total').val())
  $('#guest_booking_bed_type').val($('#confirmation_book_bed_type').val())
  $('#guest_booking_smoking_preferences').val($('#confirmation_book_smoking_preferences').val())

truncateHotelName = (hotelName) ->
  $.trim(hotelName).substring(0, 40).split(' ')
    .slice(0, -1).join(" ") + "...";

shareHotel = () ->
  $('.share-hotel-link').on 'click', ->
    $('.user_id').val $(this).data('recipient-id')
    $('#shareHotelModal .modal-header h3').text('You will share this hotel with ' + $(this).data('recipient-name'))

    hotelName = truncateHotelName($('.hotel-name:first').text())

    $('.message-image span').text hotelName
    $('.hotel_link').val window.location.href

    if $(this).data('type') is 'private_message'
      $('form.new_message').attr('action', '/conversations')
    else
      $('form.new_message').attr('action', '/conversations/send_group')

shareRecipientAutocomplete = ->
  selector = '#contact_list'

  $(selector).tokenInput( '/conversations/users_collection.json', {
    allowFreeTagging: true
    preventDuplicates: true
    zindex: 9999
    onAdd: (item)->
      $(selector).tokenInput("clear")
      
      if item.email
        if item.email is 'group'
          $('form.new_message').attr('action', '/conversations/send_group')
        else
          $('form.new_message').attr('action', '/conversations')

        $('form.new_message').get(0).reset();
        $('#shareHotelModal').modal backdrop: 'static'
        $('.user_id').val(item.id)
        $('.hotel_link').val window.location.href

        hotelName = truncateHotelName($('.hotel-name:first').text())

        $('.message-image span').text hotelName
        $('#shareHotelModal .modal-header h3').text('You will share this hotel with ' + item.name)

    prePopulate: $('#invite_user_id').data('load')
    resultsFormatter: (item) ->
      "<li><img src='#{item.image_url}' title='#{item.name}' height='50px' width='50px' /><div style='display: inline-block; padding-left: 10px;'><div class='full_name'>#{item.name}</div><div class='email'>#{item.email}</div></div></li>"
  })

  $('#messageDropdown').on 'shown.bs.dropdown', ->
    $('#token-input-user_collection').attr 'placeholder', 'Send a new message to..'


$(document).ready ->
  controller = $('body').data('controller')
  action = $('body').data('action')

  if $('.share-hotel-link').length > 0
    shareHotel()

  if controller == 'deals' && action == 'index'
    Turbolinks.pagesCached 0
    disableEnterFormSubmit()

    validateSearchForm()

    $.ajax
      url: '/deals.js'
      cache: false
      timeout: 30000

    moment.tz.add('America/Los_Angeles|PST PDT|80 70|01010101010|1Lzm0 1zb0 Op0 1zb0 Rd0 1zb0 Op0 1zb0 Op0 1zb0');
    moment.tz.link('America/Los_Angeles|US/Pacific')
    today = moment.tz('US/Pacific').format('M/D/Y')

    initDatePickerForDesktop(today)
    initDatePickerForMobile(today)
    showSearchForm()
    showSearchFormMobile()
    truncateString('input#autocomplete')
    clearSearchText('#btnClearText', 'input#autocomplete')

    showPopUpProfile()

  else if controller == 'deals' && action == 'show'
    setTimeout( ->
      coverflow = $('#coverflow').flipster()
      $('#coverflow').removeClass('on-loader')
    , 100) 
    
    initAutoNumeric('.formatted-amount', '.amount')
    initAutoNumeric('.formatted-amount', '.amount-saving')
    shareRecipientAutocomplete()

    params_path_id = window.location.pathname.split('/')[2]

    validateFormBook()
    popoverVoteTitle = $('#titlePopover').text()
    popOver('#linkPopover', popoverVoteTitle, '#contentPopover', 'click', 'top')

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

        $('.modal-lg').on 'hidden.bs.modal', (e) ->
          $('#formBook').get(0).reset()
          $('.form-book').show()
          $('.payment-errors').html("")
          # removeBackdropModal '#modalBook'

        if $('.refundable-info').length > 0
          $('body').tooltip
            selector: '.refundable-info'
            container: 'body'

        if $('.disable-book-link').length > 0
          $('.disable-book-link').tooltip()

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

        # totalCharges = $('[dom="total_charges_text"]').text().replace('$', '')
        totalCharges = $('#confirmation_book_total').val()
        $('#totalCharges').attr('data-total-charges', totalCharges)
        appendValueRoomParams()
        $('#modalSavingsForm .modal-header > h3').text $('#roomName').text()
        $('.amount').val parseFloat($('#totalCharges').data('total-charges'))

      return

    $('#recentContact').on 'shown.bs.dropdown', ->
      $('#token-input-contact_list').attr 'placeholder', 'Enter name'
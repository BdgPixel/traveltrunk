# = require jquery-main.min
# = require jquery_ujs
# = require turbolinks
# = require nprogress
# = require nprogress-turbolinks
# = require twitter/bootstrap
# = require jquery.validate
# = require jquery.parallax-1.1.3
# = require slick
# = require custom
# = require jquery.tokeninput
# = require private_pub
# = require lowlag
# = require sound_path

$(document).ajaxSend ->
  $('#loading').show()

$(document).ajaxComplete ->
  $('#loading').fadeOut("slow");

root = exports ? this
root.initAutoNumeric = (selector, hiddenSelector) ->
  $(selector).autoNumeric 'init'

  typingTimer = undefined
  doneTypingInterval = 1000
  $input = $(selector)

  doneTyping = ->
    newValue = $input.autoNumeric('get')
    $input.autoNumeric 'set', newValue
    $(hiddenSelector).val(newValue)
    return

  $input.on 'keyup', ->
    clearTimeout typingTimer
    typingTimer = setTimeout(doneTyping, doneTypingInterval)
    return

  $input.on 'keydown', ->
    clearTimeout typingTimer
    return

  $input.on 'blur focusout mouseleave', ->
    doneTyping()

root.removeBackdropModal = (selector) ->
  $(selector).on 'hidden.bs.modal', ->
    $('.modal-backdrop').remove()
    return

displayCorrectAmount = (selector) ->
  $(selector).on 'click', ->
    $('#modalCorrectAmount').modal backdrop: 'static'
    $('#formCorrectAmount').attr 'action', 'users/' + $(this).data 'id'
    $('#user_current_amount').val '$' + $(this).data('current-amount')

    return

root.showSearchForm = () ->
  if $('#slideToggleLink').length > 0
    $('.js-close-searchbox').on 'click', (e) ->
      if e.target != this
        return

      $("#slideToggle").collapse('hide')
      $('.js-arrow-desktop').css('visibility', 'visible');

      return

    $('#slideToggle').on 'show.bs.collapse', ()->
      $('.tooltip').tooltip('hide')
      $('.js-arrow-desktop').css('visibility', 'hidden');

    $('#slideToggle').on 'hide.bs.collapse', ()->
      $('.tooltip').tooltip('hide')
      $('.js-arrow-desktop').css('visibility', 'visible');

    return

root.showSearchFormMobile = () ->
  if $('#slideToggleLinkMobile').length > 0

    $('#slideToggleLinkMobile, .js-arrow-mobile').on 'click', (e) ->
      $('.tooltip').tooltip('hide')

      if $('#slideToggleLinkMobile.arrow-downs').length
        $('#slideToggleLinkMobile').removeClass 'arrow-downs'
        $('.js-arrow-mobile').css('visibility', 'hidden');
      else
        $('#slideToggleLinkMobile').addClass 'arrow-downs'
        $('.js-arrow-mobile').css('visibility', 'visible');

      return

    $('.slide').on 'click', (e) ->
      if e.target != this
        return
      $("#slideToggleMobile").collapse('hide')
      $('.js-arrow-mobile').css('visibility', 'visible');
      return

    $('.text-header-slide').on 'click', (e) ->
      if e.target != this
        return

      $("#slideToggleMobile").collapse('hide')
      $('.js-arrow-mobile').css('visibility', 'visible');

      return

    return

root.clearSearchText = (selector, target) ->
  $(selector).click ->
    $(target).val ''
    return

root.showPopUpProfile = () ->
  if $('#popUpProfile').length > 0
    $('#modalUserProfile').modal backdrop: 'static'
    $('.wrapper-titile-edit-profile').hide()
    # $('#imgProfile').hide()
    # $('#showBankAccount').hide()

  return

root.disableEnterFormSubmit = ->
  $('.search-deals-form, .search-deals-form-mobile').on 'keyup keypress', (e) ->
    code = e.keyCode or e.which
    if code == 13
      e.preventDefault()

      return false

    return

  return

root.validateSearchForm = ->
  $('.search-deals-form').validate
    ignore: ".ignore"
    rules:
      autocomplete: 'required'

    messages:
      autocomplete: 'Please enter your destination'

  return

root.validateSearchFormMobile = ->
  $('.search-deals-form-mobile').validate
    ignore: ".ignore"
    rules:
      autocomplete: 'required'

    messages:
      autocomplete: 'Please enter your destination'

  return

root.initDatePickerForDesktop = (today) ->
  $('input.search_deals_arrival_date').datepicker(
    startDate: today
    autoclose: true).on 'changeDate', (e) ->
      $(this).valid()
      departureDate = e.date
      departureDate.setDate(departureDate.getDate() + 1)

      $('input.search_deals_departure_date').datepicker('remove')
      $('input.search_deals_departure_date').datepicker
        startDate:  getFormattedDate(departureDate)
        autoclose: true
      setTimeout(->
        $('input.search_deals_departure_date').datepicker('show')
      , 100)

  $('input.search_deals_departure_date').datepicker(
    startDate: today
    autoclose: true).on 'changeDate', (e) ->

root.initDatePickerForMobile = (today) ->
  $('input.search_deals_arrival_date_mobile').datepicker(
    startDate: today
    autoclose: true).on 'changeDate', (e) ->
      $(this).valid()
      departureDate = e.date
      departureDate.setDate(departureDate.getDate() + 1)

      $('input.search_deals_departure_date_mobile').datepicker('remove')
      $('input.search_deals_departure_date_mobile').datepicker
        startDate:  getFormattedDate(departureDate)
        autoclose: true
      setTimeout(->
        $('input.search_deals_departure_date_mobile').datepicker('show')
      , 100)

  $('input.search_deals_departure_date_mobile').datepicker(
    startDate: today
    autoclose: true).on 'changeDate', (e) ->

root.truncateString = (selector) ->
  length = 50
  myString = $(selector).val()
  myTruncatedString = myString.substring(0, length)
  $(selector).val myTruncatedString

root.clearValidationMessage = ->
  $('.payment-account-error').text('')
  $('.profile-error').text('')
  $('.guest-book-error').text('')
  $('.payment-errors').html('')
  $('.saving-error').text('')

getFormattedDate = (date) ->
  day = date.getDate()
  month = date.getMonth() + 1
  year = date.getFullYear()
  formattedDate = [month, day, year].join('/')

  formattedDate

initUsersCollection = ()->
  selector = '#user_collection'

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

        $('span.errors').html('')
        $('form.new_message').get(0).reset();
        $('#newMessageModal').modal backdrop: 'static'
        $('#new_message_to').val(item.name)
        $('.user_id').val(item.id)

    prePopulate: $('#invite_user_id').data('load')
    resultsFormatter: (item) ->
      "<li><img src='#{item.image_url}' title='#{item.name}' height='50px' width='50px' /><div style='display: inline-block; padding-left: 10px;'><div class='full_name'>#{item.name}</div><div class='email'>#{item.email}</div></div></li>"
  })

  $('#messageDropdown').on 'shown.bs.dropdown', ->
    $('#token-input-user_collection').attr 'placeholder', 'Send a new message to..'

root.scrollToBottom = (selector) ->
  $('html, body').animate { scrollTop: $(document).height() }, 100
  $(selector).animate { scrollTop: $(selector).prop('scrollHeight') }, 500

showHideCollapseGroupChat = ->
  if $('.link-message:first').length > 0
    id = $('.link-message:first').attr('id').split('-')[1]

  $('span.error').html('')
  $('#collapseGroupChat').collapse 'show'
  $('#collapseGroupChat').on 'shown.bs.collapse', ->
    scrollToBottom('#groupChatBox')
  return

root.initLowLag = ->
  lowLag.init()
  lowLag.load([
    window.new_inbox_mp3_path,
    window.new_inbox_ogg_path,
    window.new_inbox_aac_path],
    "new_inbox"
  );

ready = ->
  initUsersCollection()
  initLowLag()
  
  $('.link-message').on 'click', ->
    if $(this).attr('href').indexOf("#collapseGroupChat") != -1
      showHideCollapseGroupChat()
      
  if window.location.href.indexOf("#collapseGroupChat") != -1
    showHideCollapseGroupChat()

  if $('#groupChatLink').length > 0
    $('#groupChatLink').on 'click', ->
      $('#collapseGroupChat').on 'shown.bs.collapse', ->
        scrollToBottom('#groupChatBox')

  if $('#privateChatBox').length > 0
    scrollToBottom('#privateChatBox')
    
  setTimeout(->
    $('#notice, .alert-dismissible').fadeOut()
    $('#alert').fadeOut()
  , 5000)

  $('[data-toggle="tooltip"]').tooltip()

  if $('.btn-correct-amount').length > 0
    displayCorrectAmount('.btn-correct-amount')

  if $('#btnClearText').length > 0
    clearSearchText '#btnClearText', 'input#autocomplete'

  if $('#btnClearTextMobile').length > 0
    clearSearchText '#btnClearTextMobile', 'input#autocompleteMobile'

  # Change navbar background when menu dropdown visible

  if $('body').data('controller') is 'home'
    $("#bs-example-navbar-collapse-1").on 'show.bs.collapse', () ->
      $(".transparent").addClass("scrolling")
      $("#logo-color-orange").removeClass("hide")

      $("#logo-color-white").addClass("hide")
      $("#logo-color-white").removeClass("")

      $(".btn-border").addClass("hide")
      $(".btn-border").removeClass("show")

      $(".btn-orange2").removeClass("hide")
      $(".link-top-login").addClass('grey-nav-color')

    $("#bs-example-navbar-collapse-1").on 'hidden.bs.collapse', () ->
      $(".transparent").removeClass("scrolling")
      $("#logo-color-white").removeClass("hide")
      $("#logo-color-white").addClass("")

      $("#logo-color-orange").addClass("hide")

      $(".btn-border").removeClass("show")
      $(".btn-border").addClass("show")

      $(".btn-orange2").addClass("hide")
      $(".link-top-login").removeClass('grey-nav-color')

  $(document).on "click", ".popover .close" , ()->
    $(this).parents(".popover").popover('hide');

  # hide all dropdown when scrolling
  $(window).scroll ->
    $('.dropdown').removeClass 'open'
    return


$(document).ready -> ready()
$(document).on 'page:load', -> ready()
$(document).one 'touchstart', ->
  lowLag.play()

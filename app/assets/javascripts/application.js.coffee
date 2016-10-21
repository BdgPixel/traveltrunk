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
    $('#slideToggleLink').on 'click', (e) ->
      $('.tooltip').tooltip('hide')

      if $('.arrow-downs').length
        $('#slideToggleLink').css 'padding-bottom', 0
        $('#slideToggleLink').removeClass 'arrow-downs'
      else
        $('#slideToggleLink').css 'padding-bottom', '50px'
        $('#slideToggleLink').addClass 'arrow-downs'

      return

    $('.slide').on 'click', (e) ->
      if e.target != this
        return
      $("#slideToggle").collapse('hide')
      return

    $('.text-header-slide').on 'click', (e) ->
      if e.target != this
        return
      $("#slideToggle").collapse('hide')
      $('#slideToggleLink').css 'padding-bottom', '50px'
      $('#slideToggleLink').addClass 'arrow-downs'
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
    $('#imgProfile').hide()
    # $('#showBankAccount').hide()

  return

root.disableEnterFormSubmit = ->
  $('.search-deals-form').on 'keyup keypress', (e) ->
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

root.clearValidationMessage = ->
  $('.bank-account-error').text('');
  $('.profile-error').text('');

getFormattedDate = (date) ->
  day = date.getDate()
  month = date.getMonth() + 1
  year = date.getFullYear()
  formattedDate = [month, day, year].join('/')

  formattedDate

ready = ->
  setTimeout(->
    $('#notice').fadeOut()
    $('#alert').fadeOut()
  , 5000)

  $('[data-toggle="tooltip"]').tooltip()

  if $('.btn-correct-amount').length > 0
    displayCorrectAmount('.btn-correct-amount')

  if $('#btnClearText').length > 0
    clearSearchText '#btnClearText', 'input#autocomplete'

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

$(document).ready -> ready()
$(document).on 'page:load', -> ready()
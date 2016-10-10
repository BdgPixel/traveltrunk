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

$(document).ready -> ready()
$(document).on 'page:load', -> ready()

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
  $('#searchDealsForm').on 'keyup keypress', (e) ->
    code = e.keyCode or e.which
    if code == 13
      e.preventDefault()

      return false

    return

  return

if $('#btnClearText').length > 0
  $('#btnClearText').click ->
    $('input#autocomplete').val ''

    return
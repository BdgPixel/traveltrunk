# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
# = require bootstrap.file-input.js
# = require savings_form_validation
# = require autoNumeric-min

$(document).ready ->
  initAutoNumeric('#formatted_amount_transfer', '#bank_account_amount_transfer')

  $('#profile_image').on 'click',(e) ->
    e.preventDefault()
    $('#choose_profile_image')[0].click()

    return

  $('input[type=file]').bootstrapFileInput();
  $('.file-inputs').bootstrapFileInput();

  $('#choose_profile_image').on 'change', ->
    $('#profile_image').attr('width', 226)
    $('#profile_image').attr('height', 226)
    $('#profile_image')[0].src = window.URL.createObjectURL(@files[0])
    return

# = require bootstrap.file-input
# = require savings_form_validation
# = require autoNumeric-min

root = exports ? this

root.showPopUpProfile = () ->
  if $('#popUpProfile').length > 0
    $('#modalUserProfile').modal backdrop: 'static'
    $('.wrapper-titile-edit-profile').hide()
    $('#imgProfile').hide()
    # $('#showBankAccount').hide()

  return

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
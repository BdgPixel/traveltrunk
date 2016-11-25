# = require bootstrap.file-input
# = require autoNumeric-min
# = require jquery.remotipart

uploadImage = ->
  if $('#profile_image').length > 0
    $('#profile_image').on 'click',(e) ->
      e.preventDefault()
      $('#choose_profile_image')[0].click()

      return

    $('input[type=file]').bootstrapFileInput();

    $('#choose_profile_image').on 'change', ->
      $('#profile_image').attr('width', 226)
      $('#profile_image').attr('height', 226)
      $('#profile_image')[0].src = window.URL.createObjectURL(@files[0])
      
      return

$(document).ready ->
  initAutoNumeric('#formatted_amount_transfer', '#bank_account_amount_transfer')
  uploadImage()

 
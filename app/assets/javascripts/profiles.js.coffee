# = require bootstrap.file-input
# = require savings_form_validation
# = require autoNumeric-min
#= require jquery.remotipart

root = exports ? this

ready = ->
  initAutoNumeric('#formatted_amount_transfer', '#bank_account_amount_transfer')
  uploadImage()

  # if $('form#paymentAccountProfile').length > 0
  #   paymentAccountFormValidation()

$(document).ready -> ready()
$(document).on 'page:load', -> ready()

# $(document).ready ->
#   initAutoNumeric('#formatted_amount_transfer', '#bank_account_amount_transfer')
#   uploadImage()

#   if $('form#paymentAccountProfile').length > 0
#     paymentAccountFormValidation()

  # $('#profile_image').on 'click',(e) ->
  #   e.preventDefault()
  #   $('#choose_profile_image')[0].click()

  #   return

  # $('input[type=file]').bootstrapFileInput();
  # $('.file-inputs').bootstrapFileInput();

  # $('#choose_profile_image').on 'change', ->
  #   $('#profile_image').attr('width', 226)
  #   $('#profile_image').attr('height', 226)
  #   $('#profile_image')[0].src = window.URL.createObjectURL(@files[0])
    
  #   return
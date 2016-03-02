# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
# = require autoNumeric-min

Stripe.setPublishableKey(window.stripe_publishable_key);

jQuery ($) ->
  $('#profile-payment-account').submit (event) ->

    $form = $(this)

    process_submit = true

    if $('#formatted_amount_transfer').val() == ''
      $('.amount-error').text "can't be blank"
      process_submit = false
    else
      $('.amount-error').text ''

    if $('#bank_account_transfer_frequency').val() == ''
      $('.transfer-frequency-error').text "can't be blank"
      process_submit = false
    else
      $('.transfer-frequency-error').text ""

    if process_submit
      $('#loading').show()
      # Disable the submit button to prevent repeated clicks
      $form.find('button').prop 'disabled', true

      Stripe.card.createToken $form, stripeResponseHandler
      # Prevent the form from submitting with the default action
    false
  return

stripeResponseHandler = (status, response) ->
  $form = $('#profile-payment-account')
  if response.error
    # Show the errors on the form
    $form.find('.payment-errors').text response.error.message
    $form.find('button').prop 'disabled', false
  else
    # response contains id and card, which contains additional card details
    token = response.id
    # Insert the token into the form so it gets submitted to the server
    $form.append $('<input type="hidden" name="stripeToken" />').val(token)
    # and submit
    $form.get(0).submit()

  $('#loading').fadeOut("slow");
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

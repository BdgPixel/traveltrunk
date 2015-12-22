# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require jquery.tokeninput
# = require savings_form_validation
# = require autoNumeric-min

validateInvitationForm = ->
  $('#invitationForm').validate
    ignore: ".ignore"
    rules:
      autocomplete: 'required'

    messages:
      autocomplete: 'Please enter your email invitation'

  return

clearForm = (selectorModal, selectorForm) ->
  $(selectorModal).on 'hidden.bs.modal', (e) ->
    $(selectorForm).get(0).reset()
    $('.error').text ''

  $(selectorModal).on 'shown.bs.modal', (e) ->
    $(selectorForm).get(0).reset()
    $('.error').text ''


$(document).ready ->
  validateInvitationForm()
  initAutoNumeric('#update_credit_formatted_amount', '#update_credit_amount')
  clearForm('.modal', '.promo_code')


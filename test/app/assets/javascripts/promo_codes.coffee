# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Stripe.setPublishableKey(window.stripe_publishable_key);

# jQuery ($) ->
#   $('#formPromoCode').submit (event) ->
#     $form = $(this)
#     process_submit = true

#     if !$('#promo_code_amount').val()
#       $form.find('.payment-errors.amount').text "can't be blank"
#       process_submit = false
#     else
#       $form.find('.payment-errors.amount').text ''

#     if !$('#promo_code_user_id').val()
#       $form.find('.payment-errors.user-id').text "can't be blank"
#       process_submit = false
#     else
#       $form.find('.payment-errors.user-id').text ''

#     if process_submit
#       $('#loading').show()
#       # Disable the submit button to prevent repeated clicks
#       $form.find('button').prop 'disabled', true

#       Stripe.card.createToken $form, stripeResponseHandler

#       # Prevent the form from submitting with the default action
#     false
#   return

# stripeResponseHandler = (status, response) ->
#   $form = $('#formPromoCode')

#   if response.error
#     console.log response

#     if response.error.param is 'number'
#       $form.find('.payment-errors.number').text response.error.message

#     if response.error.param is 'exp_month'
#       $form.find('.payment-errors.exp-month').text response.error.message

#     if response.error.param is 'exp_year'
#       $form.find('.payment-errors.exp-year').text response.error.message

#     # Show the errors on the forms
#     # $form.find('.payment-errors').text response.error.message
#     $form.find('button').prop 'disabled', false
#   else
#     # response contains id and card, which contains additional card details
#     token = response.id
#     # Insert the token into the form so it gets submitted to the server
#     $form.append $('<input type="hidden" name="stripeToken" />').val(token)
#     # and submit
#     $form.get(0).submit()

#   $('#loading').fadeOut("slow");
#   return

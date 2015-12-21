# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require bootstrap-datepicker

$(document).ready ->
  $('#promo_code_exp_date').datepicker
    startDate: 'today'
    autoclose: true

  $('[data-target="#modalPromoCode"]').click ->
    $('#promo_code_user_id').val $(this).attr('data-id')
    $('#promo_code_token').val $(this).attr('data-token')

  $('.modal').on 'hidden.bs.modal', (e) ->
    $('#formPromoCode').get(0).reset()
    $('#error_explanation').addClass('hide')
    $('#error_explanation li').empty()
    return

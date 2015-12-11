# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require jquery.tokeninput
# = require savings_form_validation
# = require autoNumeric

validateInvitationForm = ->
  $('#invitationForm').validate
    ignore: ".ignore"
    rules:
      autocomplete: 'required'

    messages:
      autocomplete: 'Please enter your email invitation'

  return

$(document).ready ->
  validateInvitationForm()
  initAutoNumeric('#update_credit_formatted_amount')

  $('#invite_user_id').tokenInput( '/group/users_collection.json', {
    allowCustomEntry: true
    preventDuplicates: false
    zindex: 9999
    # prePopulate: $('#invite_user_id').data('load')
    resultsFormatter: (item) ->
      "<li><img src='#{item.image_url}' title='#{item.name}' height='50px' width='50px' /><div style='display: inline-block; padding-left: 10px;'><div class='full_name'>#{item.name}</div><div class='email'>#{item.email}</div></div></li>"
    tokenFormatter: (item)->
      # "<li><img src='#{item.image_url}' title='#{item.name}' height='25px' width='25px' /><div style='display: inline-block; padding-left: 10px;'><div class='full_name'>#{item.name}</div><div class='email'>#{item.email}</div></div></li>"
      "<li><p><img src='#{item.image_url}' title='#{item.name}' height='25px' width='25px' />&nbsp;#{item.name}&nbsp;<b style='color: red'>#{item.email}</b></p></li>"
  })

  $('#slideToggleLink').click ->
    $('#slideToggle').slideToggle()

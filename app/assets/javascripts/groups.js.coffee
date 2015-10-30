# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require jquery.tokeninput
# = require holder

$(document).ready ->
  $('#invite_user_id').tokenInput( '/group/users_collection.json', {
    allowCustomEntry: true
    preventDuplicates: false
    prePopulate: $('#invite_user_id').data('load')
  })

  $('#slideToggleLink').click ->
    $('#slideToggle').slideToggle()

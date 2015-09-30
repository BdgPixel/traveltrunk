# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

$(document).ready ->
  $('#profile_birth_date').datepicker({ dateFormat: "yy-mm-dd" })

  $('#profile_image').on 'click',(e) ->
    e.preventDefault()
    $('#choose_profile_image')[0].click()
    return

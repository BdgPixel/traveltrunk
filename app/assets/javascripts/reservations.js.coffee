root = exports ? this

validateForm = ->
  $('.reservation').validate
    ignore: ".ignore"
    rules:
      itinerary: 'required'
      email: 'required'
      reason: 'required'

  return

ready = ->
  validateForm()
  
$(document).ready -> ready()
$(document).on 'page:load', -> ready()
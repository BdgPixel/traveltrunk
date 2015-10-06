# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require bootstrap-datepicker
# = require google-api
# = require jquery.validate

getFormattedDate = (date) ->
  day = date.getDate()
  month = date.getMonth() + 1
  year = date.getFullYear()
  formattedDate = [month, day, year].join('/')

  formattedDate

today = getFormattedDate(new Date)

disableEnterFormSubmit = ->
  $('.simple_form.deals').on 'keyup keypress', (e) ->
    code = e.keyCode or e.which
    if code == 13
      e.preventDefault()

      return false

    return

  return

validateSearchForm = ->
  $('#dealsForm').validate
    ignore: ".ignore"
    rules:
      autocomplete: 'required'

    messages:
      autocomplete: 'Please enter your destination'

  return

$ ->
  $('input#deals_arrival_date').datepicker(
    startDate: today).on 'changeDate', (e) ->
      $('input#deals_departure_date').datepicker('remove')
      $('input#deals_departure_date').datepicker(
        startDate:  getFormattedDate(e.date))

  $('input#deals_departure_date').datepicker startDate: today

  return

$(document).ready ->
  disableEnterFormSubmit()
  validateSearchForm()

  $('#destinationLabel').on 'click', ->
     $('#collapseDeals').slideToggle()

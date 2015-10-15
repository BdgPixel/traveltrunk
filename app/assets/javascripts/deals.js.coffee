# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require galleria
# = require bootstrap-datepicker
# = require holder
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
  $('#searchDealsForm').on 'keyup keypress', (e) ->
    code = e.keyCode or e.which
    if code == 13
      e.preventDefault()

      return false

    return

  return

validateSearchForm = ->
  $('#searchDealsForm').validate
    ignore: ".ignore"
    rules:
      autocomplete: 'required'

    messages:
      autocomplete: 'Please enter your destination'

  return

$ ->
  $('input#search_deals_arrival_date').datepicker(
    startDate: today).on 'changeDate', (e) ->
      $('input#search_deals_departure_date').datepicker('remove')
      $('input#search_deals_departure_date').datepicker(
        startDate:  getFormattedDate(e.date))

  $('input#search_deals_departure_date').datepicker startDate: today

  return

$(document).ready ->
  disableEnterFormSubmit()
  validateSearchForm()

  $('#destinationLabel').click ->
    $('#collapseDeals').slideToggle()

  if $('#galleria').length > 0
    Galleria.loadTheme window.galleria_theme_path
    Galleria.configure dummy: '/assets/default-no-image.png'
    # Initialize Galleria
    Galleria.run '#galleria'

  if $('[data-toggle="tooltip"]').length > 0
    $('[data-toggle="tooltip"]').tooltip()

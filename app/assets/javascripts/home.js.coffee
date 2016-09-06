# = require bootstrap-datepicker
# = require google-api
# = require moment
# = require moment-timezone

getFormattedDate = (date) ->
  day = date.getDate()
  month = date.getMonth() + 1
  year = date.getFullYear()
  formattedDate = [month, day, year].join('/')

  formattedDate

validateSearchForm = ->
  $('#searchDealsForm').validate
    ignore: ".ignore"
    rules:
      autocomplete: 'required'

    messages:
      autocomplete: 'Please enter your destination'

  return

$(document).ready ->
  validateSearchForm()

  moment.tz.add('America/Los_Angeles|PST PDT|80 70|01010101010|1Lzm0 1zb0 Op0 1zb0 Rd0 1zb0 Op0 1zb0 Op0 1zb0');
  moment.tz.link('America/Los_Angeles|US/Pacific')
  today = moment.tz('US/Pacific').format('M/D/Y')

  $('input#search_deals_arrival_date').datepicker(
    startDate: today
    autoclose: true).on 'changeDate', (e) ->
      departureDate = e.date
      departureDate.setDate(departureDate.getDate() + 1)

      $('input#search_deals_departure_date').datepicker('remove')
      $('input#search_deals_departure_date').datepicker
        startDate:  getFormattedDate(departureDate)
        autoclose: true
      setTimeout(->
        $('input#search_deals_departure_date').datepicker('show')
      , 100)

  $('input#search_deals_departure_date').datepicker
    startDate: today
    autoclose: true

  if $('#slideToggleLink').length > 0
    $('#slideToggleLink').on 'click', (e) ->
      $('#slideToggle').slideToggle()
      return

    $('.slide').on 'click', (e) ->
      if e.target != this
        return
      $('#slideToggle').slideUp()
      return

    $('.text-header-slide').on 'click', (e) ->
      if e.target != this
        return
      $('#slideToggle').slideUp()
      return
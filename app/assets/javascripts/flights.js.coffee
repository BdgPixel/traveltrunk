
# = require bootstrap-datepicker
# = require moment
# = require moment-timezone
# = require twitter/typeahead.min
# = require handlebars

root = exports ? this

initSelectize = (selector1, selector2)->
  depart_typeahead = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('id', 'name', 'country')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/flights/depart_typeahead?query=%QUERY'
      wildcard: '%QUERY')
  arrival_typeahead = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('id', 'name', 'country')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/flights/arrival_typeahead?query=%QUERY'
      wildcard: '%QUERY')
  $(selector1).typeahead null,
    name: 'origin-place'
    display: 'name'
    source: depart_typeahead
    templates:
      empty: Handlebars.compile('<div class="not-found"><strong>Airport not found</strong></div>')
      suggestion: Handlebars.compile('<div><img src="{{image}}"/>  <strong>({{id}})</strong> <strong>{{name}}</strong> – {{country}}</div>')
  $(selector2).typeahead null,
    name: 'origin-place'
    display: 'name'
    source: arrival_typeahead
    templates:
      empty: ('<div class="not-found"><strong>Airport not found</strong></div>')
      suggestion: Handlebars.compile('<div><img src="{{image}}"/>  <strong>({{id}})</strong> <strong>{{name}}</strong> – {{country}}</div>')

  $('.origin_place').on 'typeahead:select', (evt, item) ->
    $('#flights_origin_place_hide').val(item.id)
    return

  $('.destination_place').on 'typeahead:select', (evt, item) ->
    $('#flights_destination_place_hide').val(item.id)
    return

root.closeClollapse = ->

$(document).ready ->
  controller = $('body').data('controller')
  action = $('body').data('action')

  moment.tz.add('America/Los_Angeles|PST PDT|80 70|01010101010|1Lzm0 1zb0 Op0 1zb0 Rd0 1zb0 Op0 1zb0 Op0 1zb0');
  moment.tz.link('America/Los_Angeles|US/Pacific')
  today = moment.tz('US/Pacific').format('Y/M/D')

  disableEnterFormSubmit()
  initDatePickerFlightForDesktop(today)
  initSelectize('.origin_place', '.destination_place')
  showSearchForm()

  $('#flightForm').validate({
    ignore: ':hidden, .tt-hint'
  })
  
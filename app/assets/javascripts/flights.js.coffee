
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
  depart_typeahead = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('id', 'name', 'country')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/flights/depart_typeahead?query=%QUERY'
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
    source: depart_typeahead
    templates:
      empty: ('<div class="not-found"><strong>Airport not found</strong></div>')
      suggestion: Handlebars.compile('<div><img src="{{image}}"/>  <strong>({{id}})</strong> <strong>{{name}}</strong> – {{country}}</div>')

  $('.origin_place').on 'typeahead:select', (evt, item) ->
    $('#flights_origin_place_hide').val(item.id)
    return

  $('.destination_place').on 'typeahead:select', (evt, item) ->
    $('#flights_destination_place_hide').val(item.id)
    return

$(document).ready ->
  controller = $('body').data('controller')
  action = $('body').data('action')
  moment.tz.add('America/Los_Angeles|PST PDT|80 70|01010101010|1Lzm0 1zb0 Op0 1zb0 Rd0 1zb0 Op0 1zb0 Op0 1zb0');
  moment.tz.link('America/Los_Angeles|US/Pacific')
  today = moment.tz('US/Pacific').format('Y/M/D')
  disableEnterFormSubmit()
  initDatePickerFlightForDesktop(today)
  initSelectize('.origin_place', '.destination_place')
  $('#flightForm').validate({
    ignore: ':hidden, .tt-hint'
  })
  $('.gallery-wrap').each ->
    childrenCount = undefined
    childrenCount = $(this).find('img').length - 1
    $(this).attr('data-cur', childrenCount).attr 'data-total', childrenCount
    $(this).find('img').each (i) ->
      $(this).attr 'data-num', i
      return
    return
  $('.gallery-wrap').mousemove (e) ->
    current = undefined
    offset = undefined
    part = undefined
    section = undefined
    totalCount = undefined
    totalWidth = undefined
    offset = e.offsetX
    totalWidth = $(this).outerWidth()
    totalCount = parseInt($(this).attr('data-total'))
    part = totalWidth / (totalCount + 1)
    section = parseInt(totalCount - Math.floor(offset / part))
    current = parseInt($(this).attr('data-cur'))
    if current != section
      $(this).attr 'data-cur', section
      $(this).append $(this).find('img[data-num="' + section + '"]').detach()
    return

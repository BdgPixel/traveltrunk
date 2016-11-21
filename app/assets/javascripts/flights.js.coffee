
# = require bootstrap-datepicker
# = require moment
# = require moment-timezone
# = require selectize

root = exports ? this

initSelectize = ->
	$('#origin_place').selectize({
		maxItems: 1
	})
	$('#destination_place').selectize({
		maxItems: 1
	})

$(document).ready ->
  controller = $('body').data('controller')
  action = $('body').data('action')
  today = moment.tz('US/Pacific').format('Y/M/D')
  disableEnterFormSubmit()
  initDatePickerFlightForDesktop(today)
  initSelectize()

  $('#flightForm').validate()
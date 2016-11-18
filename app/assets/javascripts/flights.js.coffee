
# = require bootstrap-datepicker
# = require moment
# = require moment-timezone

root = exports ? this

$(document).ready ->
  controller = $('body').data('controller')
  action = $('body').data('action')
  today = moment.tz('US/Pacific').format('Y/M/D')
  disableEnterFormSubmit()
  initDatePickerFlightForDesktop(today)

  $('#flightForm').validate()
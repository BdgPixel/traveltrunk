# = require blueimp-gallery
# = require blueimp-gallery-indicator
# = require jquery.lazyload
# = require bootstrap-datepicker
# = require google-api
# = require jquery.simplePagination
# = require jquery.raty
# = require ratyrate
# = require savings_form_validation
# = require autoNumeric-min
# = require moment
# = require moment-timezone

root = exports ? this

$(document).ready ->
  controller = $('body').data('controller')
  action = $('body').data('action')
  today = moment.tz('US/Pacific').format('Y/M/D')
  #validateFlightSearchForm()
  initDatePickerFlightForDesktop(today)
  initDatePickerForMobile(today)
  showSearchForm()
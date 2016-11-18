# = require jquery.lazyload
# = require bootstrap-datepicker
# = require google-api
# = require jquery.simplePagination
# = require moment
# = require moment-timezone

root = exports ? this

root.initDealsPage = (numOfpages, numOfHotels)->
  if numOfpages && numOfHotels && numOfHotels > 15
    $('#pagination')
      .pagination
        pages: numOfpages
        cssStyle: 'light-theme'
        displayedPages: 3
        edges: 1
        onPageClick: (pageNumber, event)->
          selectedPage = $("#page-#{pageNumber}")
          selectedPage.show()
          $(".deal-pages").not(selectedPage).hide()
          $('html, body').animate { scrollTop: 0 }, 'slow'

          prevPage = pageNumber - 1
          startRange = (prevPage * 15) + 1
          endRange = pageNumber * 15
          endRange = numOfHotels if endRange > numOfHotels
          $("p#pagination-info").text(startRange + " - " + endRange + ' of ' + numOfHotels + " Hotels")

          false

  $('div.lazy').lazyload()

$(document).ready ->
  disableEnterFormSubmit()
  validateSearchForm()
  validateSearchFormMobile()

  moment.tz.add('America/Los_Angeles|PST PDT|80 70|01010101010|1Lzm0 1zb0 Op0 1zb0 Rd0 1zb0 Op0 1zb0 Op0 1zb0');
  moment.tz.link('America/Los_Angeles|US/Pacific')
  today = moment.tz('US/Pacific').format('M/D/Y')

  initDatePickerFlightForDesktop(today)
  initDatePickerForDesktop(today)
  initDatePickerForMobile(today)
  showSearchForm()
  showSearchFormMobile()

  numOfpages = $('#valueOfPagination').data('num-of-pages')
  numOfHotels = $('#valueOfPagination').data('num-of-hotels')

  initDealsPage(numOfpages, numOfHotels)

  $('.price-deals').tooltip()
  $('#slideToggleLink').tooltip()
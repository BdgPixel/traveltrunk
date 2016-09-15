# = require jquery.lazyload
# = require bootstrap-datepicker
# = require google-api
# = require jquery.simplePagination
# = require moment
# = require moment-timezone

root = exports ? this

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

  showSearchForm()

  numOfpages = $('#valueOfPagination').data('num-of-pages')
  numOfHotels = $('#valueOfPagination').data('num-of-hotels')

  initDealsPage(numOfpages, numOfHotels)

  $('.price-deals').tooltip()
  $('#slideToggleLink').tooltip()
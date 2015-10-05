# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

tmp = $.fn.popover.Constructor::show
$.fn.popover.Constructor::show = ->
  tmp.call this
  if @options.callback
    @options.callback()
  return

$(document).ready ->

  $('[data-toggle="popover"]').popover
    html: true
    title: 'Search Hotel'
    content: ->
      $('#popover-content').html()
    callback: ->
      $('input#deals_arrival_date').datepicker
        todayHighlight: true

      $('input#deals_departure_date').datepicker
        todayHighlight: true

      return

  return


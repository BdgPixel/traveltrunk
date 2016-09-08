# = require jquery-main.min
# = require jquery_ujs
# = require turbolinks
# = require nprogress
# = require nprogress-turbolinks
# = require twitter/bootstrap/dropdown
# = require twitter/bootstrap/modal
# = require twitter/bootstrap/tooltip
# = require twitter/bootstrap/popover
# = require twitter/bootstrap/collapse
# = require twitter/bootstrap/alert
# = require jquery.validate
# = require jquery.parallax-1.1.3
# = require custom

$(document).ajaxSend ->
  $('#loading').show()

$(document).ajaxComplete ->
  $('#loading').fadeOut("slow");

ready = ->
  setTimeout(->
    $('#notice').fadeOut()
    $('#alert').fadeOut()
  , 5000)
  
$(document).ready -> ready()
$(document).on 'page:load', -> ready()

root = exports ? this
root.initAutoNumeric = (selector, hiddenSelector) ->
  $(selector).autoNumeric 'init'

  typingTimer = undefined
  doneTypingInterval = 1000
  $input = $(selector)

  doneTyping = ->
    newValue = $input.autoNumeric('get')
    $input.autoNumeric 'set', newValue
    $(hiddenSelector).val(newValue)
    return

  $input.on 'keyup', ->
    clearTimeout typingTimer
    typingTimer = setTimeout(doneTyping, doneTypingInterval)
    return
  $input.on 'keydown', ->
    clearTimeout typingTimer
    return

  $input.on 'blur focusout mouseleave', ->
    doneTyping()

root.removeBackdropModal = (selector) ->
  $(selector).on 'hidden.bs.modal', ->
    $('.modal-backdrop').remove()
    return
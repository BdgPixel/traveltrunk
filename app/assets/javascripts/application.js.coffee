# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.

# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.

# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.

# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.

# = require jquery
# = require jquery_ujs
# = require turbolinks
# = require nprogress
# = require nprogress-turbolinks
# = require twitter/bootstrap/dropdown
# = require twitter/bootstrap/modal
# = require jquery.validate
# = require bootstrap.file-input

$(document).ajaxSend ->
  $('#loading').show()

$(document).ajaxComplete ->
  $('#loading').fadeOut("slow");

$(document).ready ->
  setTimeout(->
    $('#notice').fadeOut()
    $('#alert').fadeOut()
  , 4000)

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

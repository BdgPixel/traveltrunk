# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# = require jquery.tokeninput
# = require savings_form_validation
# = require autoNumeric-min

validateInvitationForm = ->
  $('#invitationForm').validate
    ignore: ".ignore"
    rules:
      autocomplete: 'required'

    messages:
      autocomplete: 'Please enter your email invitation'

  return

disableEnterFormSubmit = ->
  $('#invitationForm').on 'keyup keypress', (e) ->
    code = e.keyCode or e.which
    if code == 13
      e.preventDefault()

      return false

    return

  return

clearForm = (selectorModal, selectorForm) ->
  $(selectorModal).on 'hidden.bs.modal', (e) ->
    $(selectorForm).get(0).reset()
    $('.error').text ''

  $(selectorModal).on 'shown.bs.modal', (e) ->
    $(selectorForm).get(0).reset()
    $('.error').text ''

showInviteNotification = ->
  setTimeout (->
    unregisteredUsers = $('#invite_user_id').val().split(',').filter((item) ->
      /\S+@\S+\.\S+/.test item
    )
    console.log unregisteredUsers
    if unregisteredUsers.length > 0
      $('.noticeEmail').html "<b>Notice: </b>#{unregisteredUsers.join(", ")} does not have an account with us yet. Send them an email to join Travel Trunk for your next trip together."
      $('.noticeEmail').show()
    else
      $('.noticeEmail').hide()

    return
  ), 500

inviteFriends = (selector) ->
  $(selector).tokenInput( '/group/users_collection.json', {
      # allowCustomEntry: true
      allowFreeTagging: true
      preventDuplicates: true
      zindex: 9999
      onAdd: (item)->
        if item.email
          item
        else
          re = /\S+@\S+\.\S+/;
          if re.test(item.name)
            item
          else
            $(selector).tokenInput("remove", {name: item.name});
            console.log 'You only can enter email address for unregistered users'

        showInviteNotification()
      onDelete: (item) ->
        $(selector).tokenInput("remove", { name: item.name });
        showInviteNotification()

      prePopulate: $('#invite_user_id').data('load')
      resultsFormatter: (item) ->
        "<li><img src='#{item.image_url}' title='#{item.name}' height='50px' width='50px' /><div style='display: inline-block; padding-left: 10px;'><div class='full_name'>#{item.name}</div><div class='email'>#{item.email}</div></div></li>"
      tokenFormatter: (item)->
        console.log item
        if isNaN(item.id)
          tags = "<li><p><img src='#{default_image_user_path}' title='#{item.name}' height='25px' width='25px' />&nbsp;#{item.name}</p></li>"
          tags
        else
          "<li><p><img src='#{item.image_url}' title='#{item.name}' height='25px' width='25px' />&nbsp;#{item.name}&nbsp;<b style='color: red'>#{item.email}</b></p></li>"
    })


$(document).ready ->
  validateInvitationForm()
  disableEnterFormSubmit()
  initAutoNumeric('#update_credit_formatted_amount', '#update_credit_amount')
  clearForm('.modal', '.promo_code')
  inviteFriends('#invite_user_id')



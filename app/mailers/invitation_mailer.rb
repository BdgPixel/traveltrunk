class InvitationMailer < ApplicationMailer
  def invite(current_user, user_invite)
    user = User.select(:email).find user_invite.user_id

    @invite = user_invite
    @current_user = current_user

    mail to: user.email, subject: 'TravelTrunk Invitation Group'
  end
end

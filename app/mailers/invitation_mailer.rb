class InvitationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.invitation_mailer.invite.subject
  #
  def invite(user_invite)
    user = User.select(:email).find user_invite.user_id

    @invite = user_invite

    mail to: user.email, subject: 'TravelTrunk Invitation Group'
  end
end

class InvitationMailer < ApplicationMailer
  def invite(current_user, user_invite)
    user = User.select(:email).find user_invite.user_id

    @invite = user_invite
    @current_user = current_user

    mail to: user.email, subject: 'TravelTrunk Invitation Group'
  end

  def information_after_invited(joined_user)
    user = User.select(:email).find(joined_user)
    @user_group = UsersGroup.find_by(user_id: joined_user)

    mail to: user.email, subject: 'TravelTrunk Information'
  end
end

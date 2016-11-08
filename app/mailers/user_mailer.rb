class UserMailer < ApplicationMailer
  helper DealsHelper
  helper ReservationsHelper

  def welcome(user)
    @user = user   
    mail to: @user.email, subject: 'Welcome to TravelTrunk'
  end
end

class HelpMailer < ApplicationMailer
  def send_question(help_params)
    @help_message = help_params[:message]
    @sender_email = help_params[:email]
    mail to: 'maryssa@traveltrunk.us', subject: help_params[:subject], from: help_params[:email]
  end
end

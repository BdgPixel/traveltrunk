class HelpMailer < ApplicationMailer
  def send_question(help_params)
    @help_message = help_params[:message]
    mail to: 'msalomon@traveltrunkusa.com', subject: help_params[:subject], from: help_params[:email]
  end
end

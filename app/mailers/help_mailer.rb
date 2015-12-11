class HelpMailer < ApplicationMailer
  def send_to_mailer(help_params)
    @help_message = help_params[:message]
    mail to: 'helptraveltrunk@mailinator.com', subject: help_params[:subject]
  end
end

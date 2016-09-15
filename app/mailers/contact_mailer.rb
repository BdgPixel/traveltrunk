class ContactMailer < ApplicationMailer
  helper ApplicationHelper

  def send_message(contact_params)
    @contact = contact_params
    mail to: "msalomon@traveltrunkusa.com", subject: contact_params[:subject], from: contact_params[:email]
  end
end

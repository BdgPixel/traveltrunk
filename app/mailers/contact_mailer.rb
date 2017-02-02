class ContactMailer < ApplicationMailer
  helper ApplicationHelper

  def send_message(contact_params)
    @contact = contact_params
    mail to: "maryssa@traveltrunk.us", subject: contact_params[:subject], from: contact_params[:email]
  end
end

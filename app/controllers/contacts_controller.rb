class ContactsController < ApplicationController
  def index
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      ContactMailer.send_message(@contact).deliver_now
      redirect_to contact_us_url, notice: 'Your message was successfully sent'
    else
      render :index
    end
  end

  private
    def contact_params
      params.require(:contact).permit(:first_name, :last_name, :email, :subject, :message)
    end
end

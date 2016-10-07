class PoliciesController < ApplicationController
  layout 'static_page'

  def privacy; end

  def refund
    @contact = Contact.new
  end

  def create_contact
    @contact = Contact.new(contact_params)

    if @contact.save
      ContactMailer.delay.send_message(@contact)
      redirect_to refund_policy_url, notice: 'Your message was successfully sent'
    else
      flash[:alert] = "First name, last name, email, subject, or message can't be blank"
      render :refund
    end
  end

  private
    def contact_params
      params.require(:contact).permit(:first_name, :last_name, :email, :subject, :message)
    end
end

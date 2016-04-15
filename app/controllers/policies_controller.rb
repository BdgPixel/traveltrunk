class PoliciesController < ApplicationController
  def privacy; end

  def refund
    @contact = Contact.new
  end

  def create_contact
    @contact = Contact.new(contact_params)

    if @contact.save
      ContactMailer.send_message(@contact).deliver_now
      redirect_to refund_policy_url, notice: 'Your message was successfully sent'
    else
      render :refund
    end
  end

  private
    def contact_params
      params.require(:contact).permit(:first_name, :last_name, :email, :subject, :message)
    end
end

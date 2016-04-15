class RefundMailer < ApplicationMailer
  def approved(refund)
    @refund = refund
    
    mail to: @refund.user.email, subject: 'Refund Successfully Approved'
  end
end
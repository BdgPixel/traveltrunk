class HelpsController < ApplicationController
  def index
  end

  def send_question
    if params[:question][:email].blank? || params[:question][:subject].blank? || params[:question][:message].blank?
      redirect_to helps_path, alert: "Email, subject, or message can't be blank"
    else
      HelpMailer.send_question(params[:question]).deliver_now
      redirect_to helps_path, notice: "Thank you! You're message has been sent. You get back to you shortly"
    end
  end
end

class HelpsController < ApplicationController
  def index
  end

  def send_to_mailer
    HelpMailer.send_to_mailer(params[:send_to_mailer]).deliver_now
    redirect_to helps_path, notice: "Successfully"
  end
end

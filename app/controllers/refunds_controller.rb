class RefundsController < ApplicationController
  before_action :set_public_activity, only: :create

  def create
    refund = current_user.refunds.new(trans_id: params[:trans_id], amount: @activity.parameters[:amount] * 100)

    if refund.save
      @activity.parameters[:is_request_refund] = true
      @activity.save

      redirect_to notifications_url, notice: 'Your request successfully sent'
    end
  end

  private
    def set_public_activity
      @activity = PublicActivity::Activity.find(params[:id])
    end

end

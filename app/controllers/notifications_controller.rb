class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    PublicActivity::Activity.where(recipient_id: current_user.id, is_read: false)
      .update_all(is_read: true)

    @activities = current_user.get_notification
    @current_total_credit = current_user.total_credit
  end
end

class NotificationsController < ApplicationController
  def index
    PublicActivity::Activity.where(recipient_id: current_user.id, is_read: false)
      .update_all(is_read: true)

    @activities = current_user.get_notification
  end
end

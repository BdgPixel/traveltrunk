class NotificationsController < ApplicationController
  def index
    @activities = PublicActivity::Activity.order("created_at desc")
    # yuhuu
  end
end

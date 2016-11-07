class SavingsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_group, only: :index
  before_action :get_group_messages
  skip_before_action :get_message_notifications

  def index
    unless current_user.profile.home_airport
      redirect_to edit_profile_url(no_profile: true)
    end

    if params[:open_group_chat]
      @group.message.conversation.first.read_notification!(current_user.id)
    end
    
    get_message_notifications
  end
end

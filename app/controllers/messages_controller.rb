class MessagesController < ApplicationController
  skip_before_action :get_message_notifications, only: :show
  before_action :authenticate_user!
  before_action :set_message, only: [:show, :reply, :update_status]
  before_action :get_group, only: [:users_collection, :show, :reply_group, :send_group]

  def show
    if @message.is_last?
      @conversations = @message.conversation.reverse
      @conversations.last.try(:read_notification!, current_user.id)
        
      get_message_notifications
    else
      redirect_to message_url(@message.conversation.first)
    end
  end

  def users_collection
    users_list = User.get_user_collection(params[:q], current_user.id)
    
    if @group
      default_user_img = ActionController::Base.new.view_context.asset_path "default_user.png"
      users_list << { id: @group.id, name: @group.name, email: 'group', image_url: default_user_img }
    end
    
    respond_to do |format|
      format.json { render json: users_list.reverse }
    end
  end

  def create
    body_message = 
      if message_params[:share_image]
        tmp_body = "[shared: #{message_params[:share_image]}|#{message_params[:hotel_name]}|#{message_params[:hotel_link]}]"
        tmp_body << message_params[:body] if message_params[:body]
      else
        message_params[:body]
      end

    @recipient = User.find message_params[:user_id]
    @first_message = current_user.messages.between(current_user.id, @recipient.id).last
    
    if @first_message
      @message = current_user.reply_to(@first_message, body_message)
    else
      @message = current_user.send_message(@recipient, body_message)
    end

    # @notification = @message.create_activity key: "messages.private", owner: current_user,
    #   recipient: @recipient, trackable_type: 'CustomMessage'

    @notification = PublicActivity::Activity.new(
      key: "messages.private",
      owner: current_user,
      recipient: @recipient,
      trackable_id: @message.id,
      trackable_type: 'CustomMessage'
    )

    @notification.save

    @message_count = @message.received_messageable.messages.conversations.select { |c| 
      !c.opened if c.received_messageable_id.eql?(@message.received_messageable_id) }.count

    respond_to { |format| format.js }
  end

  def send_group
    body_message = 
      if message_params[:share_image]
        tmp_body = "[shared: #{message_params[:share_image]}|#{message_params[:hotel_name]}|#{message_params[:hotel_link]}]"
        tmp_body << message_params[:body] if message_params[:body]
      else
        message_params[:body]
      end

    is_owner = current_user.group.present?

    members = @group.all_members
    message_hash = { topic: 'Group Message', body: body_message }

    @first_message = @group.message
    
    if @first_message.present?
      @message = current_user.reply_to(@first_message, message_hash)
    else
      @first_message = @message = current_user.send_message(@group.members.first, message_hash)
      @group.update(message_id: @message.id)
    end
    
    respond_to do |format|
      if @message.errors.any?
        format.js
      else
        members.each do |member|
          # notification = @message.create_activity key: "messages.group", owner: current_user,
          #   recipient: member

          notification = PublicActivity::Activity.new(
            key: "messages.group",
            owner: current_user,
            recipient: member,
            trackable_id: @message.id,
            trackable_type: 'CustomMessage'
          )

          notification.save
          @notification = notification if member.id.eql?(current_user.id)
        end

        format.js
      end
    end
  end

  def reply
    @first_message = @message.conversation.last
    @reply_message = current_user.reply_to(@first_message, message_params[:body])

    respond_to do |format|
      if @reply_message.errors.any?
        format.js
      else
        @notification = PublicActivity::Activity.new(
          key: "messages.private",
          owner: current_user,
          recipient: @reply_message.received_messageable,
          trackable_id: @reply_message.id, trackable_type: 'CustomMessage'
        )

        @notification.save

        @message_count = @first_message.received_messageable.messages.conversations
          .select { |c| !c.opened if c.received_messageable_id.eql?(@reply_message.received_messageable_id) }.count
      end
    
      format.js
    end
  end

  def reply_group
    message_hash = { topic: 'Group Message', body: message_params[:body] }
    @reply_message = current_user.reply_to(@group.message, message_hash)
    @message = @group.message

    @group.all_members.each do |member|
      @reply_message.create_activity key: "messages.group", owner: current_user,
        recipient: member
    end

    respond_to { |format| format.js }
  end

  private
    def set_message
      @message = CustomMessage.find(params[:id]) rescue nil
      redirect_to savings_url, notice: "No conversations found for that id" unless @message
    end

    def message_params
      params.require(:new_message).permit(:user_id, :to, :body, :share_image, :hotel_name, :user_id,
        :hotel_link)
    end
end

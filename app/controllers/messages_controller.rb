class MessagesController < ApplicationController
  skip_before_action :get_messages, only: :show
  before_action :set_message, only: [:show, :reply]
  before_action :get_group, only: [:users_collection]

  def show
    @conversations = @message.conversation.reverse

    if @conversations.last.received_messageable_id.eql? current_user.id
      @conversations.last.open
    end
      
    get_messages
  end

  def users_collection
    users_list = User.get_user_collection(params[:q], current_user.id)
    
    if @group
      users_list << { id: @group.id, name: @group.name, email: '', image_url: '/assets/default_user.png' }
    end
    
    # binding.pry
    respond_to do |format|
      format.json { render json: users_list.reverse }
    end
  end

  def create
    @recipient = User.find message_params[:user_id]
    @first_message = current_user.messages.between(current_user.id, @recipient.id).last
    
    if @first_message
      @message = current_user.reply_to(@first_message, message_params[:body])
    else
      @message = current_user.send_message(@recipient, message_params[:body])
    end

    @message_count = @message.received_messageable.messages.conversations.select { |c| !c.opened }.count
    respond_to { |format| format.js }
  end

  def send_group
    group = current_user.group || current_user.joined_groups.first
    is_owner = current_user.group.present?

    member = group.members.select { |m| m unless m.id.eql? current_user.id }.last
    @recipient = is_owner ? (member || current_user) : group.user
    message_hash = { topic: 'Group Message', body: message_params[:body] }

    if group.message_id
      @first_message = group.message
      @message = current_user.reply_to(@first_message, message_hash)
    else
      @message = current_user.send_message(@recipient, message_hash)
      group.update(message_id: @message.id)
    end
    
    @message_count = @message.received_messageable.messages.conversations.select { |c| !c.opened }.count
    respond_to { |format| format.js }
  end

  def reply
    @reply_message = current_user.reply_to(@message, message_params[:body])
    @first_message = @reply_message.conversation.last

    @message_count = @first_message.received_messageable.messages
      .conversations.select { |c| !c.opened }.count
    
    respond_to do |format|
      format.js
    end
  end

  def reply_group
    
  end

  private
    def set_message
      @message = CustomMessage.find params[:id]
    end

    def message_params
      params.require(:new_message).permit(:user_id, :to, :body)
    end
end

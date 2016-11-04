class MessagesController < ApplicationController
  skip_before_action :get_messages, only: :show
  before_action :set_message, only: [:show, :reply]

  def show
    @conversations = @message.conversation.reverse

    if @conversations.last.received_messageable_id.eql? current_user.id
      @conversations.last.open
    end
      
    get_messages
  end

  def users_collection
    users_list = User.get_user_collection(params[:q], current_user.id)

    respond_to do |format|
      format.json { render json: users_list }
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
    @first_message = group.user.messages.select { |m| m if m.topic }.last

    @recipient = is_owner ? (member || current_user) : group.user
    message_hash = { topic: 'Group Message', body: message_params[:body] }

    @message = 
      if is_owner
        send_or_reply_message(@first_message, @recipient, message_hash)
      else
        send_or_reply_message(@first_message, @recipient, message_hash)
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

    def send_or_reply_message(first_message, recipient, message_hash)
      if first_message && first_message.topic
        current_user.reply_to(first_message, message_hash)
      else
        current_user.send_message(recipient, message_hash)
      end
    end
end

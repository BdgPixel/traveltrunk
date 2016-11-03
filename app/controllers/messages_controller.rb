class MessagesController < ApplicationController
  skip_before_action :get_messages, only: :show
  before_action :set_message, only: [:show, :reply]

  def show
    @conversations = @message.conversation.reverse
    @conversations.last.open
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
    @first_message = current_user.messages.between(current_user.id ,@recipient.id).last
    
    if @first_message
      @message = current_user.reply_to(@first_message, message_params[:body])
    else
      @message = current_user.send_message(@recipient, message_params[:body])
    end
    
    respond_to { |format| format.js }
  end

  def reply
    @reply_message = current_user.reply_to(@message, message_params[:body])
    @first_message = @reply_message.conversation.last
    
    respond_to do |format|
      format.js
    end
  end

  private
    def set_message
      @message = CustomMessage.find params[:id]
    end

    def message_params
      params.require(:new_message).permit(:user_id, :to, :body)
    end
end

class MessagesController < ApplicationController
  skip_before_action :get_messages, only: :show
  before_action :set_message, only: [:show, :reply]

  def index
    @messages = current_user.messages.conversations
  end

  def show
    @message.open
    @conversations = @message.conversation.reverse
    @messages = current_user.messages.conversations
  end

  def users_collection
    users_list = User.get_autocomplete_data(params[:q], current_user.id)

    respond_to do |format|
      format.json { render json: users_list }
    end
  end

  def create
    recipient = User.find message_params[:user_id]
    current_message = current_user.messages.are_to(recipient).first

    if current_message
      @current_conversation = current_message.conversation.first
      @message = current_user.reply_to(@current_conversation, message_params[:body])
    else
      @message = current_user.send_message(recipient, message_params[:body])
    end

    respond_to { |format| format.js }
  end

  def reply
    current_user.reply_to(@message, message_params[:body])
    redirect_to message_url(@message)
  end

  private
    def set_message
      @message = ActsAsMessageable::Message.find params[:id]
    end

    def message_params
      params.require(:new_message).permit(:user_id, :to, :body)
    end
end

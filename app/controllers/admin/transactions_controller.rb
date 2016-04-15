class Admin::TransactionsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @transactions = Transaction.order(created_at: :desc).page params[:page]
  end
end

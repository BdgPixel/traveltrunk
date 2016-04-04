class Admin::TransactionsController < ApplicationController
  def index
    @transactions = Transaction.order(created_at: :desc).page params[:page]
  end
end

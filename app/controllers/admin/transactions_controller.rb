class Admin::TransactionsController < ApplicationController
  def index
    @transactions = Transaction.all.page params[:page]
  end
end

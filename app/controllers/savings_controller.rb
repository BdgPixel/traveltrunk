class SavingsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_group, only: :index

  def index; end
end

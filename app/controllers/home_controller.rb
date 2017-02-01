class HomeController < ApplicationController
  before_action :set_action_form_search
  before_action :get_group, only: :search
  before_action :get_destination, only: :search

  def index
    @destination = Destination.new(session[:destination]) if session[:destination].present?
  end

  def search
  	@referre = params[:referrer]
  end

  private
  	def get_destination
  		if user_signed_in?
  			@is_get_destination = true
  		  @destinationable = @group || current_user
  		  @destination = @destinationable.destination
  		else
		  	@destination = Destination.new(session[:destination]) if session[:destination].present?
  		end
  	end
end

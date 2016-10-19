class HomeController < ApplicationController
  before_action :set_action_form_search

  def index
    @destination = Destination.new(session[:destination]) if session[:destination].present?
  end
end

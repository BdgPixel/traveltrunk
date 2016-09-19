class HomeController < ApplicationController
  def index
    @destination = Destination.new(session[:destination]) if session[:destination].present?
  end
end

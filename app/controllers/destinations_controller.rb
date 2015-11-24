class DestinationsController < ApplicationController
  def clear
    Destination.delete_all
    redirect_to deals_path
  end
end

class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def new
    @profile = Profile.new
  end

  def show
    @profile = current_user.profile

    unless @profile
      redirect_to new_profile_path, notice: "You haven't entered your profile. \n
        Please fill information below"
    end
  end

  def edit
    @profile = current_user.profile
  end

  def create
    @profile = current_user.build_profile(profile_params)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to profile_url, notice: 'Profile was successfully created.' }
        format.json { render :show }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if current_user.profile.update_attributes(profile_params)
        format.html { redirect_to profile_url, notice: 'Profile was successfully updated.' }
        format.json { render :show }
      else
        format.html { render :edit }
        format.json { render json: current_user.profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def profile_params
      params.require(:profile).permit(:first_name, :last_name, :birth_date, :home_airport,
        :gender, :address, :address_1, :address_2, :city, :state, :postal_code, :country, :image, :image_cache)
    end
end

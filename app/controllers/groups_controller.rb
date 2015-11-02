class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @joined_members = @group.members.select(:id, :email).map { |u| { id: u.id, name: u.email } }
  end

  def users_collection
    users_list = User.get_autocomplete_data(params[:q], current_user.id)

    respond_to do |format|
      format.json { render json: users_list }
    end
  end

  def invite
    group = current_user.group

    unless group
      group = Group.create(name: "#{current_user.profile.first_name}'s Group", user_id: current_user.id)
      # group = current_user.group.create(name: "#{current_user.profile.first_name}'s Group")
    end

    group_hashs = params[:invite][:user_id].split(',').uniq
      .map { |u| { user_id: u, group_id: group.id } }

    users_groups = UsersGroup.create(group_hashs)

    respond_to do |format|
      format.html { redirect_to savings_path, notice: 'User was successfully invited.' }
      format.json { render :show, status: :created }
    end
  end

  def accept_invitation
    user_group = UsersGroup.find_by(invitation_token: params[:token])

    respond_to do |format|
      if user_group.update_attributes(accepted_at: Time.now)
        format.html { redirect_to savings_path, notice: 'You were successfully join the group.' }
        format.json { render :show, status: :ok}
      end
    end

  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    @group.user_id = current_user.id

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params[:group]
      params.require(:group).permit(:name, :user_id)
    end
end

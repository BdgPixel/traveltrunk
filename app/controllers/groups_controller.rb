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
    @activities = PublicActivity::Activity.all
  end

  def users_collection
    users_list = User.get_autocomplete_data(params[:q])

    respond_to do |format|
      format.json { render json: users_list }
    end
  end

  def invite
    group_hashs = params[:invite][:user_id].split(',').uniq
      .map { |u| { user_id: u, group_id: params[:id] } }
    # group_hashs = [{ user_id: params[:invite][:user_id], group_id: params[:id] }]
    users_groups = UsersGroup.create(group_hashs)

    users_groups.each do |users_group|
      InvitationMailer.invite(users_group).deliver_now
    end

    respond_to do |format|
      format.html { redirect_to group_path(params[:id], notice: 'User was successfully invite.') }
      format.json { render :show, status: :created }
    end
  end

  def confirmation_group
    # redirect_to group_url
    # yuhuu
    user_group = UsersGroup.find_by(invitation_token: params[:id])

    respond_to do |format|
      if user_group.update_attributes(accepted_at: Time.now)
        format.html { redirect_to group_path(user_group.group_id), notice: 'User was successfully join the group.' }
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

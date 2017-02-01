# == Schema Information
#
# Table name: users_groups
#
#  id               :integer          not null, primary key
#  invitation_token :string
#  accepted_at      :datetime
#  user_id          :integer
#  group_id         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class UsersGroup < ActiveRecord::Base
  include PublicActivity::Model

  belongs_to :member, class_name: "User", foreign_key: :user_id
  belongs_to :joined_group, class_name: "Group", foreign_key: :group_id

  before_destroy :destroy_likes
  before_create :set_invitation_token
  after_create :send_invitation_notification

  def generate_invitation_token
    random_token = SecureRandom.urlsafe_base64(nil, false)
    if self.class.exists?(invitation_token: random_token)
      random_token = generate_invitation_token
    end
    random_token
  end

  def accept_invitation
    self.create_activity key: "group.accept_invitation", owner: self.member,
      recipient: self.joined_group.user, parameters: { token: self.invitation_token }
  end

  private
    def set_invitation_token
      self.invitation_token = generate_invitation_token
    end

    def send_invitation_notification
      current_user = self.joined_group.user
      self.create_activity key: "group.invitation_sent", owner: current_user,
        recipient: User.find(self.user_id), parameters: { token: self.invitation_token, group_id: current_user.id }
    end

    def destroy_likes
      self.member.likes.destroy_all
    end
end

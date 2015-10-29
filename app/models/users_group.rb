class UsersGroup < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }

  belongs_to :member, class_name: 'User', foreign_key: :user_id
  belongs_to :joined_group, class_name: 'Group', foreign_key: :group_id

  before_create :set_invitation_token

  def generate_invitation_token
    random_token = SecureRandom.urlsafe_base64(nil, false)
    if self.class.exists?(invitation_token: random_token)
      random_token = generate_invitation_token
    end
    random_token
  end

  def set_invitation_token
    self.invitation_token = generate_invitation_token
  end
end

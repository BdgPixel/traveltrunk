class Group < ActiveRecord::Base
  extend FriendlyId

  has_many :members, -> { where('users_groups.accepted_at IS NOT NULL') }, through: :users_groups
  has_many :users_groups, dependent: :destroy
  has_one :destination, as: :destinationable
  belongs_to :user

  friendly_id :name, use: [:slugged, :finders]

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  def total_credit
    members = self.members.select(:total_credit)
    members.map(&:total_credit).sum + self.user.total_credit
  end
end

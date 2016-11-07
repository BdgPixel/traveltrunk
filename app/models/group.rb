class Group < ActiveRecord::Base
  extend FriendlyId

  has_many :members, -> { where('users_groups.accepted_at IS NOT NULL') }, through: :users_groups
  has_many :users_groups, dependent: :destroy
  has_one :destination, as: :destinationable
  belongs_to :user
  belongs_to :message, class_name: 'CustomMessage'

  friendly_id :name, use: [:slugged, :finders]

  before_destroy :destroy_destination

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  def total_credit
    members = self.members.select(:total_credit)
    members.map(&:total_credit).sum + self.user.total_credit
  end

  def all_members
    self.members.to_a << self.user
  end

  private
    def destroy_destination
      self.destination.destroy if self.destination
    end
end

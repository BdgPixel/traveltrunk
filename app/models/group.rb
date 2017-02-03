# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  name       :string
#  slug       :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  message_id :integer
#

class Group < ActiveRecord::Base
  extend FriendlyId

  has_many :members, -> { where('users_groups.accepted_at IS NOT NULL') }, through: :users_groups
  has_many :users_groups, dependent: :destroy
  has_one :destination, as: :destinationable
  belongs_to :user
  belongs_to :message, class_name: 'CustomMessage'

  friendly_id :name, use: [:slugged, :finders]

  before_destroy :destroy_destination
  before_destroy :destroy_likes
  # after_destroy :destory_messages

  # delegate the law of demeter rails best practice
  delegate :total_credit, to: :user, prefix: true

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

    def destroy_likes
      Like.where(user_id: self.member_ids).destroy_all
    end

    def destory_messages
      CustomMessage.where('id = ? OR ancestry = ?', self.message_id, self.message_id.to_s).destroy_all
      PublicActivity::Activity.where(trackable_id: self.message_id).destroy_all
    end
end

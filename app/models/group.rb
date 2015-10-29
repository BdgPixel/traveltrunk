class Group < ActiveRecord::Base
  extend FriendlyId

  has_many :members, through: :users_groups
  has_many :users_groups

  friendly_id :name, use: [:slugged, :finders]

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end

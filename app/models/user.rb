class User < ActiveRecord::Base
  has_one :profile
  has_one :bank_account
  has_many :likes
  has_many :destinations
  has_many :joined_groups, through: :users_groups
  has_many :users_groups
  has_one :group

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :bank_account

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable


  def no_profile?
    self.profile.nil? || self.profile.new_record?
  end

  def full_name
    full_name = "#{self.profile.first_name} #{self.profile.last_name}".titleize
  end

  def get_notification(is_read = true)
    PublicActivity::Activity.order("created_at desc")
      .where(recipient_id: self.id, recipient_type: "User", is_read: is_read)
  end

  def self.get_autocomplete_data(email, current_user)
    self.joins(:profile).select("users.id, users.email, profiles.first_name")
    .where("(LOWER(profiles.first_name) LIKE LOWER(:keyword) OR users.email LIKE :keyword)
      AND users.id NOT IN (:ids)", { keyword: "%#{email}%", ids: current_user} )
    .map {|u| { id: u.id, name: "#{u.first_name} (#{u.email})" } }
  end

end

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

  def self.get_autocomplete_data(email, current_user)
    self.includes(:profile).select(:id, :email).where('email LIKE ? AND id NOT IN (?)', "#{email}%", current_user)
      .map {|u| { id: u.id, name: "#{u.email} (#{u.profile.first_name})" } }
  end
end

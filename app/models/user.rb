class User < ActiveRecord::Base
  has_one :profile
  has_one :bank_account
  has_many :likes
  has_many :destinations
  has_many :groups, through: :users_groups
  has_many :users_groups

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

  def self.get_autocomplete_data(email)
    self.select(:id, :email).where('email LIKE ?', "#{email}%").map {|u| {id: u.id, name: u.email} }
  end

end

class Profile < ActiveRecord::Base
  belongs_to :user

  mount_uploader :image, ImageUploader

  validates :first_name, :last_name, :birth_date, :address,
    :city, :state, :postal_code, presence: true
  validates :gender, presence: { message: 'please select one' }
  validates :country, presence: { message: 'please select one' }

end

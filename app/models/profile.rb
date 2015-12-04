class Profile < ActiveRecord::Base
  belongs_to :user

  mount_uploader :image, ImageUploader

  validates :first_name, :last_name, :birth_date, :address,
    :city, :state, :postal_code, :favorite_place, :vacation_moment,
    :travel_destination, presence: true

  validates :gender, presence: { message: 'please select one' }
  validates :country_code, presence: { message: 'please select one' }

  def country_name
    country = ISO3166::Country[self.country_code]
    country.translations[I18n.locale.to_s] || country.name
  end
end

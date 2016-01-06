class Profile < ActiveRecord::Base
  belongs_to :user

  mount_uploader :image, ImageUploader

  validates :first_name, :last_name, presence: true
  validates :birth_date, :address,
    :city, :state, :postal_code, :home_airport, :place_to_visit, presence: true, if: :validate_personal_information?

  validates :gender, presence: { message: 'please select one' }, if: :validate_personal_information?
  validates :country_code, presence: { message: 'please select one' }, if: :validate_personal_information?

  attr_accessor :validate_personal_information

  def country_name
    country = ISO3166::Country[self.country_code]
    country.translations[I18n.locale.to_s] || country.name
  end

  def validate_personal_information?
    validate_personal_information
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def address_valid?
    city && state && country_code && postal_code
  end
end

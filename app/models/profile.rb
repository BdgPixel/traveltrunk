# == Schema Information
#
# Table name: profiles
#
#  id             :integer          not null, primary key
#  first_name     :string
#  last_name      :string
#  birth_date     :date
#  gender         :string
#  address        :string
#  address_1      :string
#  address_2      :string
#  city           :string
#  state          :string
#  postal_code    :string
#  country_code   :string
#  image          :string
#  user_id        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  home_airport   :text
#  place_to_visit :text
#

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
    "#{self.first_name} #{self.last_name}".titleize
  end

  def pronoun(type)
    if self.gender
      case type
      when 'object' then self.gender.eql?('Male') ? 'him' : 'her'
      when 'subject' then self.gender.eql?('Male') ? "He's" : "She's"
      when 'possesive' then self.gender.eql?('Male') ? 'his' : 'her'
      end
    else
      case type
      when 'object' then 'him / her'
      when 'subject' then "He's / She's"
      when 'possesive' then self.gender.eql?('Male') ? 'his' : 'her'
      end
    end
  end

  def address_valid?
    city && state && country_code && postal_code
  end

  def change_to_hash(args)
    hash = {}

    if args.is_a? Array
      args.each do |index|
        camel_case_to_snake_case = index.first.underscore
        hash[camel_case_to_snake_case] = index.last
      end
    else
      hash = args.attributes
      hash['email'] = self.user.email
      hash['country'] = self.country_code
      hash['zip'] = self.postal_code
      hash['merchant_customer_id'] = nil
      hash['company'] = nil
      hash['phone_number'] = nil
      hash['fax_number'] = nil
    end
    hash
  end

  def get_profile_hash(profile_params = nil)
    to_array = []
    to_hash = {}

    if profile_params
      profile_array = [profile_params.paymentProfiles.first.billTo]

      profile_array.first.roxml_references.each do |xml_reference|
        to_array << [xml_reference.opts.accessor, profile_array.map(&:"#{xml_reference.opts.accessor}").first]
      end

      to_array.push(['email', profile_params.email], ['merchant_customer_id', profile_params.merchantCustomerId])
      to_hash = change_to_hash(to_array)
    else
      to_hash = change_to_hash(self)
    end

    to_hash
  end
end

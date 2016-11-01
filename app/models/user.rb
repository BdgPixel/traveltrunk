class User < ActiveRecord::Base
  include PublicActivity::Model

  acts_as_messageable :required   => :body,
                      :dependent  => :destroy

  paginates_per 10

  scope :non_admin, -> { where(admin: false).order(created_at: :desc) }

  has_one  :profile, dependent: :destroy
  has_one  :bank_account, dependent: :destroy
  has_one  :group, dependent: :destroy
  has_one  :customer, dependent: :destroy
  has_one  :subscription, dependent: :destroy
  has_one  :destination, dependent: :destroy, as: :destinationable

  has_many :promo_codes, dependent: :destroy
  has_many :likes
  has_many :joined_groups, -> { where("users_groups.accepted_at IS NOT NULL") } , through: :users_groups
  has_many :users_groups, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :identities, dependent: :destroy

  accepts_nested_attributes_for :profile

  attr_accessor :stripe_token, :execute_stripe_callbacks, :group_id

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :async,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  def no_profile?
    self.profile.nil? || self.profile.new_record?
  end

  def full_name
    "#{self.profile.first_name} #{self.profile.last_name}".titleize
  end

  def total_credit_in_usd
    (self.total_credit / 100.0).round
  end

  def total_credit_in_cents(total_credit)
    self.total_credit += total_credit * 100
  end

  def get_notification(is_read = true)
    PublicActivity::Activity.order("created_at desc")
      .where(recipient_id: self.id, recipient_type: "User", is_read: is_read)
  end

  def expedia_room_params(hotel_id, destination, group, rate_code = nil, room_type_code = nil)
    room_hash = {}
    
    if destination
      current_search = destination.get_search_params(group)

      room_hash[:hotelId]       = hotel_id.to_s
      room_hash[:arrivalDate]   = current_search[:arrivalDate]
      room_hash[:departureDate] = current_search[:departureDate]


      if rate_code && room_type_code
        room_hash[:rateCode]     = rate_code
        room_hash[:roomTypeCode] = room_type_code
      end

      room_hash[:includeRoomImages] = 'true'
      room_hash[:options]           = "ROOM_TYPES"
      room_hash[:includeDetails]    = 'true'

      room_hash[:RoomGroup] = {
        'Room' => {
          'numberOfAdults' => group ? group.members.size.next.to_s : destination.number_of_adult.to_s
        }
      }
    end

    room_hash
  end

  def self.get_autocomplete_data(email, current_user)
    User.joins("FULL OUTER JOIN profiles ON profiles.user_id = users.id")
      .joins("FULL OUTER JOIN users_groups ON users_groups.user_id = users.id")
      .joins("FULL OUTER JOIN groups ON groups.user_id = users.id")
      .select("users.id, users.email, users.admin, profiles.first_name, profiles.image")
      .where("(LOWER(profiles.first_name) LIKE LOWER(:keyword) OR users.email LIKE :keyword)
        AND users.id NOT IN (:ids)", { keyword: "%#{email}%", ids: [current_user]} )
      .where("users.admin = ?", false)
      .where("users_groups.user_id IS NULL OR users.id IS NULL")
      .where("groups.user_id IS NULL OR users.id IS NULL")
      .map {|u| { id: u.id, name: "#{u.profile.try(:first_name) || 'No Name'}", email: u.email, image_url: u.profile.try(:image_url) || '/assets/default_user.png' } }
  end

  def self.list_of_user_collections
    user_collections = []
    self.includes(:profile).select(:id).where(admin: false).map do |user|
      user_collections << ["#{user.profile.first_name} #{user.profile.last_name}", user.id].to_a if user.profile
    end
    user_collections
  end

  def self.find_for_oauth(auth)
    @user = self.find_by(email: auth.info.email)

    if @user
      identity = Identity.find_for_oauth(auth, @user.id)
    else
      unless @user
        @user = User.new
        @user.build_profile
        @user.email = auth.info.email
        @user.password = Devise.friendly_token[0, 20]
        @user.profile.first_name = auth.info.first_name
        @user.profile.last_name = auth.info.last_name
        @user.profile.gender = auth.extra.raw_info.gender
        @user.profile.remote_image_url = auth.info.image
        @user.profile.validate_personal_information = false

        @user.identities.create(provider: auth.provider, uid: auth.uid) if @user.save
      end
    end

    @user
  end
end

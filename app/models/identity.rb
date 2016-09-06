class Identity < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_for_oauth(auth, user_id)
    self.where(uid: auth.uid, provider: auth.provider, user_id: user_id).first_or_create
  end
end

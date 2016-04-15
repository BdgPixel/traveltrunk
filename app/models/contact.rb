class Contact < ActiveRecord::Base
  validates :first_name, :last_name, :email, :subject, :message, presence: true
end

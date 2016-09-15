class Like < ActiveRecord::Base
  include PublicActivity::Model

  belongs_to :user

  private
    def send_notification_to_groups
      self.user.joined_groups.first.members.each do |user|
        unless user.id.eql?(self.user_id)
          self.create_activity key: "group.like", owner: self.user,
            recipient: User.find(user.id), parameters: { hotel_id: self.hotel_id }
        end
      end
    end
end

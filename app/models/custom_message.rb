# == Schema Information
#
# Table name: messages
#
#  id                         :integer          not null, primary key
#  topic                      :string
#  body                       :text
#  received_messageable_id    :integer
#  received_messageable_type  :string
#  sent_messageable_id        :integer
#  sent_messageable_type      :string
#  opened                     :boolean          default(FALSE)
#  recipient_delete           :boolean          default(FALSE)
#  sender_delete              :boolean          default(FALSE)
#  created_at                 :datetime
#  updated_at                 :datetime
#  ancestry                   :string
#  recipient_permanent_delete :boolean          default(FALSE)
#  sender_permanent_delete    :boolean          default(FALSE)
#

class CustomMessage < ActsAsMessageable::Message
  include PublicActivity::Model

  scope :between, -> (sender_id, recipient_id) {
    where('((sent_messageable_id = :sender_id AND received_messageable_id = :recipient_id)
      OR (sent_messageable_id = :recipient_id AND received_messageable_id = :sender_id))
      AND topic IS NULL',
      { sender_id: sender_id, recipient_id: recipient_id })
  }

  validate :body

  def read_notification!(user_id)
    self.custom_activities.where(recipient_id: user_id).update_all(is_read: true)
  end

  def is_last?
    self.id.eql? self.conversation.first.id
  end

  def sender_name
    self.sent_messageable.try(:profile).try(:full_name)
  end

  def recipient_name
    self.received_messageable.try(:profile).try(:full_name)
  end

  def sent_by?(user_id)
    self.sent_messageable_id.eql?(user_id)
  end

  def is_group_chat?
    self.topic.eql? 'Group Message'
  end

  def custom_activities
    PublicActivity::Activity.where(trackable_type: 'CustomMessage', trackable_id: self.id)
  end
end

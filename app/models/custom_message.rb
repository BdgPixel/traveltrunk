class CustomMessage < ActsAsMessageable::Message
  include PublicActivity::Model

  scope :between, -> (sender_id, recipient_id) { 
    where('(sent_messageable_id = :sender_id AND received_messageable_id = :recipient_id)
      OR (sent_messageable_id = :recipient_id AND received_messageable_id = :sender_id)',
      { sender_id: sender_id, recipient_id: recipient_id })
  }

  def read_notification!(user_id)
    self.activities.where(recipient_id: user_id).update_all(is_read: true)
  end

  def is_last?
    self.id.eql? self.conversation.first.id
  end
end
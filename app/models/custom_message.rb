class CustomMessage < ActsAsMessageable::Message
  scope :between, -> (sender_id, recipient_id) { 
    where('(sent_messageable_id = :sender_id AND received_messageable_id = :recipient_id)
      OR (sent_messageable_id = :recipient_id AND received_messageable_id = :sender_id)',
      { sender_id: sender_id, recipient_id: recipient_id })
  }
end
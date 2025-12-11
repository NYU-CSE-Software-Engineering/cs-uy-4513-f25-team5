class Conversation < ApplicationRecord
  belongs_to :participant_one, class_name: 'User'
  belongs_to :participant_two, class_name: 'User'
  has_many :messages, dependent: :destroy

  validates :participant_one_id, uniqueness: { scope: :participant_two_id }
  validate :participants_are_different
  validate :no_duplicate_conversation

  def other_participant(user)
    participant_one_id == user.id ? participant_two : participant_one
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  def participant?(user)
    participant_one_id == user.id || participant_two_id == user.id
  end

  private

  def participants_are_different
    if participant_one_id == participant_two_id
      errors.add(:base, "Cannot create a conversation with yourself")
    end
  end

  def no_duplicate_conversation
    return if participant_one_id.nil? || participant_two_id.nil?
    
    existing = Conversation.where(
      "(participant_one_id = ? AND participant_two_id = ?) OR (participant_one_id = ? AND participant_two_id = ?)",
      participant_one_id, participant_two_id, participant_two_id, participant_one_id
    ).where.not(id: id).exists?
    
    if existing
      errors.add(:base, "Conversation already exists between these users")
    end
  end
end
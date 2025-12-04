class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validate :body_not_blank

  def body_not_blank
    if body.nil? || body.strip.empty?
      errors.add(:body, "can't be blank")
    end
  end




  validates :conversation_id, presence: true
  validates :user_id, presence: true

  validate :user_must_be_conversation_participant

  scope :recent, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }

  private

  def user_must_be_conversation_participant
    return unless conversation && user
    
    unless conversation.participant?(user)
      errors.add(:user, "must be a participant in the conversation")
    end
  end
end
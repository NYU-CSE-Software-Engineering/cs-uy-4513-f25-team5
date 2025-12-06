class Report < ApplicationRecord
  VALID_REPORT_TYPES = ['Harassment', 'Spam', 'Inappropriate Content', 'Other']

  belongs_to :reporter, class_name: 'User'
  belongs_to :reported_user, class_name: 'User', optional: true

  attr_accessor :reported_username

  validates :report_type, presence: true, inclusion: { in: VALID_REPORT_TYPES }
  validates :reporter, presence: true
  validates :reported_username, presence: true

  before_validation :set_reported_user
  validate :reported_user_exists
  validate :cannot_report_self

  private

  def set_reported_user
    return if reported_username.blank?
    
    user = User.find_by(email: reported_username)
    self.reported_user = user if user.present?
  end

  def reported_user_exists
    if reported_username.present? && reported_user.nil?
      errors.add(:reported_username, "User does not exist")
    end
  end

  def cannot_report_self
    if reporter.present? && reported_user.present? && reporter.id == reported_user.id
      errors.add(:reported_username, "Cannot report yourself")
    end
  end
end
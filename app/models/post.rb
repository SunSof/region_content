class Post < ApplicationRecord
  belongs_to :user
  belongs_to :region

  has_many_attached :images
  has_many_attached :files

  before_validation :set_default_status

  validates :title, :content, :region,  presence: true
  validates :status, inclusion: { in: ['draft', 'pending_review', 'approved', 'rejected'] }

  scope :by_region, ->(region_id) { where(region_id: region_id) if region_id.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_publish_date, ->(start_date, end_date) {
    where(published_at: start_date.beginning_of_day..end_date.end_of_day) if start_date.present? && end_date.present?
  }

  private

  def set_default_status
    self.status ||= 'draft'
  end
end

class Post < ApplicationRecord
  include Filterable

  belongs_to :user
  belongs_to :region

  has_many_attached :images
  has_many_attached :files

  scope :by_region, ->(region_id) { where(region_id: region_id) if region_id.present? }
  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_publish_date, ->(start_date, end_date) {
    where(published_at: start_date.to_date.beginning_of_day..end_date.to_date.end_of_day) if start_date.present? && end_date.present?
  }

  validates :title, :content, :region,  presence: true
  validates :status, inclusion: { in: ['draft', 'pending_review', 'approved', 'rejected'] }

  before_validation :set_default_status

  def data_time_formatter
    published_at.strftime("%d.%m.%Y %H:%M")
  end

  private

  def set_default_status
    self.status ||= 'draft'
  end
end

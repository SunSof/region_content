class Post < ApplicationRecord
  belongs_to :user
  has_many_attached :images
  has_many_attached :files

  before_validation :set_default_status

  validates :title, :content, :region,  presence: true
  validates :status, inclusion: { in: ['draft', 'pending_review', 'approved', 'rejected'] }

  private

  def set_default_status
    self.status ||= 'draft'
  end
end

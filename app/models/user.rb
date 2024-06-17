class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  belongs_to :region, optional: true

  validates :role, inclusion: { in: ['user', 'admin'] }
  validates :first_name, :last_name, :middle_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validate :region_presence_for_user

  before_validation :email_downcase

  authenticates_with_sorcery!

  def admin?
    role == 'admin'
  end

  private

  def region_presence_for_user
    if role == 'user' && region_id.blank?
      errors.add(:region_id, "must be selected")
    end
  end

  def email_downcase
    self.email = email.downcase if email.present?
  end
end

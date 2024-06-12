class User < ApplicationRecord
  authenticates_with_sorcery!

  before_validation :email_downcase
  # before_create :set_admin_region, if: :admin?
  before_save :set_admin_region, if: :admin?

  validates :role, inclusion: { in: ['user', 'admin'] }

  validates :first_name, :last_name, :middle_name, :region, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }


  private

  def email_downcase
    self.email = email.downcase if email.present?
  end

  def admin?
    role == 'admin'
  end

  def set_admin_region
    self.region = 'all_regions'
  end
end

class User < ApplicationRecord
  has_secure_password

  has_one :cart, dependent: :destroy
  has_many :orders

  before_validation :generate_jti, on: :create
  before_validation :generate_google_uid, on: :create

  validates :email, presence: true, uniqueness: true
  validates :jti, presence: true, uniqueness: true
  validates :google_uid, uniqueness: true, allow_blank: true

  private

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end

  def generate_google_uid
    self.google_uid ||= SecureRandom.uuid
  end
end

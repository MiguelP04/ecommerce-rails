class User < ApplicationRecord
  has_secure_password

  has_one :cart, dependent: :destroy
  has_many :orders

  before_validation :generate_jti, on: :create
  before_validation :set_default_role, on: :create

  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, length: { minimum: 8 }
  validates :jti, presence: true, uniqueness: true
  validates :google_uid, uniqueness: true, allow_blank: true

  private

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end

  def set_default_role
    self.role ||= "user"
  end
end

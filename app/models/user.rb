class User < ApplicationRecord
    before_validation :generate_jti, on: :create

    validates :google_uid, presence: true, uniqueness: true
    validates :jti, presence: true, uniqueness: true

    private

    def generate_jti
        self.jti ||= SecureRandom.uuid
    end
end
class Option < ApplicationRecord
    has_many :option_values, dependent: :destroy

    validates :name, presence: true, uniqueness: true
end

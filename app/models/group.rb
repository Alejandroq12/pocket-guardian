class Group < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3, maximum: 65 }
  validates :icon, presence: true
  belongs_to :user
  has_many :movements, dependent: :destroy
end

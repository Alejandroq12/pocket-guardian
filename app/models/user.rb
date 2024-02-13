class User < ApplicationRecord
  validates :name, presence: true, length: { minimun: 3, maximum: 65 }

  has_many :groups, dependent: :destroy
  has_many :movements, foreign_key: 'author_id', dependent: :destroy
end

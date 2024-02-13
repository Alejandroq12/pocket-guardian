class User < ApplicationRecord
  has_many :groups, dependent: :destroy
  has_many :movements, foreign_key: 'author_id', dependent: :destroy
end

class Movement < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3, maximum: 65 }
  validates :amount, presence: true, numericality: { greater_than: 0 }, length: { maximum: 10 }
  validates :user_id, presence: true
  validates :group_id, presence: true

  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :group
end

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  validates :name, presence: true, length: { minimum: 3, maximum: 65 }

  has_many :groups, dependent: :destroy
  has_many :movements, foreign_key: 'author_id', dependent: :destroy
end

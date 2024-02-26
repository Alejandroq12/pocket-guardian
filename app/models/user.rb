class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  validates :name, presence: true, length: { minimum: 3, maximum: 65 }
  validates :profile_image, presence: true, allow_blank: false

  has_many :groups, dependent: :destroy
  has_many :movements, foreign_key: 'author_id', dependent: :destroy

  def self.profile_images
    Dir.glob('app/assets/images/profile_images/*').map { |file| File.basename(file) }
  rescue StandardError => e
    Rails.logger.error "Failed to load icons: #{e.message}"
  end
end

class Group < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3, maximum: 65 }
  # validates :icon, presence: true
  validates :icon, presence: true, inclusion: { in: proc { Group.icon_choices } }

  belongs_to :user
  has_many :movements, dependent: :destroy

  def self.icon_choices
    Dir.glob('app/assets/images/group_icons/*').map { |file| File.basename(file) }
  end
end

class Group < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3, maximum: 65 }
  validates :icon, presence: true, inclusion: { in: proc { Group.icon_choices } }
end

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name, presence: true
  validates :user_type, presence: true, inclusion: { in: [ "developer", "manager", "qa" ] }

  # enum user_type: { developer: 0, manager: 1, qa: 2 }
end

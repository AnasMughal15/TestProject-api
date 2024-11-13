class User < ApplicationRecord
  before_create :set_jti
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :name, presence: true
  validates :user_type, presence: true, inclusion: { in: [ "developer", "manager", "qa" ] }

  has_many :projects_as_manager, class_name: "Project", foreign_key: "manager_id", dependent: :destroy
  has_many :project_users, dependent: :destroy
  has_many :projects, through: :project_users
  has_many :bugs, dependent: :destroy


  def set_jti
    Digest::MD5.hexdigest("#{id}:#{updated_at}")
  end
  # enum user_type: { developer: 0, manager: 1, qa: 2 }
  def manager?
    user_type == "manager"
  end
  def developer?
    user_type == "developer"
  end
  def qa?
    user_type == "qa"
  end
end

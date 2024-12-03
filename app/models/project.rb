class Project < ApplicationRecord
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
  has_many :project_users, dependent: :destroy
  has_many :developers, through: :project_users, source: :user
  has_many :bugs, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  # validate :manager_must_be_valid
  # validates :assign_developer
  
  # this is for in case we have to send a notfication in term of any commit
  # after_destroy :thisIsAfterSave
 

  def manager_must_be_valid
    unless manager&.user_type == "manager"
      errors.add(:manager_id, "must belong to a user with the 'manager' role")
    end
  end

  def assign_developer(user)
    # Check if the developer is already assigned to another project
    if developers.include?(user)
      errors.add(:developers, "developer is already assigned to the project")
      false
    else
      self.developers << user
    end
  end

  scope :with_manager_and_developers, -> {
    select("projects.*, users.name AS manager_name")
      .joins("JOIN users ON users.id = projects.manager_id")
  }

  def developer_ids
    project_users.where(role: "developer").pluck(:user_id)
  end

  def self.filter_by_role(user)
    if user.manager?
      for_manager(user.id)
    elsif user.developer?
      for_developer(user.id)
    elsif user.qa?
      for_qa
    else
      none
    end
  end

  def self.for_manager(manager_id)
    where(manager_id: manager_id).with_manager_and_developers
  end

  # Fetch projects assigned to a specific developer, including developer IDs and manager name
  def self.for_developer(user_id)
    joins(:project_users)
      .where(project_users: { user_id: user_id })
      .with_manager_and_developers
  end

  # Fetch all projects for QA, including developer IDs and manager name
  def self.for_qa
    with_manager_and_developers
  end

  # Search scope
  def self.search(term)
    where("LOWER(projects.name) LIKE :term OR LOWER(projects.description) LIKE :term", term: "#{term.downcase}%")
  end

  def thisIsAfterSave
    # debugger
    newRecord = Project.new(name: "ans", description: "hello", manager_id: 5)
    newRecord.save
  end
end

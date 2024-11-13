class Project < ApplicationRecord
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
  has_many :project_users, dependent: :destroy
  has_many :developers, through: :project_users, source: :user
  has_many :bugs, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true

  def assign_developer(user)
    # Check if the developer is already assigned to another project
    if developers.include?(user)
      errors.add(:developers, "developer is already assigned to this project")
      false
    else
      self.developers << user
    end
  end

  scope :with_manager_and_developers, -> {
    select("projects.*, users.name AS manager_name")
      .joins("JOIN users ON users.id = projects.manager_id")
      .map do |project|
        # Get developers working on this project
        developers = User.joins(:project_users)
                         .where(project_users: { project_id: project.id, role: "developer" })
                         .select(:id, :name)

        # Format developers as an array of hashes with id and name
        developer_list = developers.map { |dev| { id: dev.id, name: dev.name } }

        # Merge additional information into the project JSON response
        project.as_json.merge(
          manager_name: project.manager_name,
          developers: developer_list
        )
      end
  }

  # Get developer IDs for each project
  def developer_ids
    project_users.where(role: "developer").pluck(:user_id)
  end

  # Fetch projects for a manager, including developer IDs and manager name
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
end

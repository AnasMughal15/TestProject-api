class ProjectUser < ApplicationRecord
  belongs_to :project
  belongs_to :user
  validates :role, presence: true, inclusion: { in: [ "developer", "manager", "qa" ] }
end

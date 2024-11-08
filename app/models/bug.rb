class Bug < ApplicationRecord
  belongs_to :project
  belongs_to :creator, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true

  validates :title, presence: true, uniqueness: { scope: :project_id }
  validates :status, presence: true, inclusion: { in: [ "new", "started", "resolved", "completed" ] }
  validates :type, presence: true, inclusion: { in: [ "feature", "bug" ] }
end

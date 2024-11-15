# app/models/bug.rb
class Bug < ApplicationRecord
  belongs_to :project
  belongs_to :creator, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true

  validates :title, presence: true, uniqueness: { scope: :project_id }
  validates :status, presence: true, inclusion: { in: %w[new started resolved completed] }
  validates :bug_type, presence: true, inclusion: { in: %w[feature bug] }
  validates :creator, presence: true
  validates :assignee, presence: true, if: -> { assignee.present? && project.project_users.include?(assignee) }

  # Ensure only QA users can create bugs
  validate :creator_is_qa

  private

  def creator_is_qa
    errors.add(:creator, "must be a QA user") unless creator.user_type == "qa"
  end
end

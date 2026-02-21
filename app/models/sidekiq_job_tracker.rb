class SidekiqJobTracker < ApplicationRecord
  STATUSES = %w[enqueued running completed failed].freeze

  validates :job_id, presence: true, uniqueness: true
  validates :job_class, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(enqueued_at: :desc) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id job_id job_class queue status arguments enqueued_at started_at completed_at failed_at error created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end

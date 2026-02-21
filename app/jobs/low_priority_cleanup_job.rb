class LowPriorityCleanupJob < ApplicationJob
  include Trackable

  queue_as :low

  def perform(resource_type)
    Rails.logger.info "[LowPriorityCleanupJob] Cleaning up old records for: #{resource_type}"
    # Replace with real cleanup logic (e.g. purge old attachments, logs)
  end
end

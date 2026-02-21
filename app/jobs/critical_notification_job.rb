class CriticalNotificationJob < ApplicationJob
  include Trackable

  queue_as :critical

  def perform(message)
    Rails.logger.info "[CriticalNotificationJob] Sending urgent notification: #{message}"
    # Replace with real notification logic (e.g. email, SMS, push)
  end
end

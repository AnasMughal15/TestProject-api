module Trackable
  extend ActiveSupport::Concern

  included do
    before_enqueue do |job|
      SidekiqJobTracker.create!(
        job_id:      job.job_id,
        job_class:   job.class.name,
        queue:       job.queue_name,
        status:      "enqueued",
        enqueued_at: Time.current,
        arguments:   job.arguments.to_json
      )
    end
  end
end

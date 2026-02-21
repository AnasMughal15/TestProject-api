class SidekiqJobTrackerMiddleware
  def call(worker, job, queue)
    active_job_id = job.dig("args", 0, "job_id") || job["job_id"]
    tracker = SidekiqJobTracker.find_by(job_id: active_job_id)
    tracker&.update(status: "running", started_at: Time.current)

    yield

    tracker&.update(status: "completed", completed_at: Time.current)
  rescue => e
    tracker&.update(status: "failed", failed_at: Time.current, error: e.message)
    raise
  end
end

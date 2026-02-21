require Rails.root.join("app/middlewares/sidekiq_job_tracker_middleware")

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

  config.server_middleware do |chain|
    chain.add SidekiqJobTrackerMiddleware
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end

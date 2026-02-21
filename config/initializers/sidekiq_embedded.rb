# Runs Sidekiq inside the Puma web process in production (no separate worker service needed).
# Trade-off: saves cost but shares memory with Puma. Fine for portfolio/low-traffic apps.
# To revert to a separate worker: remove this file and re-enable the worker in render.yaml.
#
# Guard: defined?(Puma) ensures this only runs when the web server boots,
# not during assets:precompile or db:migrate.
if Rails.env.production? && defined?(Puma)
  Thread.new do
    require "sidekiq/cli"
    cli = Sidekiq::CLI.instance
    cli.parse([ "-C", "config/sidekiq.yml" ])
    cli.run
  end
end

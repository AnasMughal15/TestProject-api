ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# Load config/application.yml into ENV before database.yml is parsed
yaml_file = File.expand_path("application.yml", __dir__)
if File.exist?(yaml_file)
  require "yaml"
  config = YAML.safe_load(File.read(yaml_file), aliases: true) || {}
  rails_env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
  shared    = config.reject { |k, _| %w[development test production].include?(k) }
  env_config = config[rails_env] || {}
  shared.merge(env_config).each { |key, value| ENV[key.to_s] ||= value.to_s }
end

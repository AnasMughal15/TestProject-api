class AddArgumentsToSidekiqJobTrackers < ActiveRecord::Migration[7.2]
  def change
    add_column :sidekiq_job_trackers, :arguments, :text
  end
end

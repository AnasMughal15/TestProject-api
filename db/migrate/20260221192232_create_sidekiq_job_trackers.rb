class CreateSidekiqJobTrackers < ActiveRecord::Migration[7.2]
  def change
    create_table :sidekiq_job_trackers do |t|
      t.string :job_id
      t.string :job_class
      t.string :queue
      t.string :status
      t.datetime :enqueued_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :failed_at
      t.text :error

      t.timestamps
    end

    add_index :sidekiq_job_trackers, :job_id, unique: true
    add_index :sidekiq_job_trackers, :status
    add_index :sidekiq_job_trackers, :job_class
  end
end

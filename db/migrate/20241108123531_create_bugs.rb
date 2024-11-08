class CreateBugs < ActiveRecord::Migration[7.2]
  def change
    create_table :bugs do |t|
      t.string :title, null: false
      t.text :description
      t.string :type, null: false, default: 'bug'
      t.string :status, null: false, default: 'new'
      t.references :project, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :assignee, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :bugs, [ :title, :project_id ], unique: true
  end
end

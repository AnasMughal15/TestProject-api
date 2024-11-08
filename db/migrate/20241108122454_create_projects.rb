class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.references :manager, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end

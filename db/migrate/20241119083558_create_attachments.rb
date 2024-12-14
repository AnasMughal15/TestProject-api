class CreateAttachments < ActiveRecord::Migration[7.0]
  def change
    create_table :attachments do |t|
      t.references :bug, null: false, foreign_key: true
      t.string :file_name, null: false
      t.string :file_path, null: false

      t.timestamps
    end
  end
end

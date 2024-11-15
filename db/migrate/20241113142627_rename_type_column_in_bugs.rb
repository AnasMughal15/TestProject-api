class RenameTypeColumnInBugs < ActiveRecord::Migration[7.2]
  def change
    rename_column :bugs, :type, :bug_type
  end
end

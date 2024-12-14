class ChangeAssigneeIdNullInBugs < ActiveRecord::Migration[6.0]
  def change
    change_column_null :bugs, :assignee_id, false
  end
end

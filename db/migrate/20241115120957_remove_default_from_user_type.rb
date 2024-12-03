class RemoveDefaultFromUserType < ActiveRecord::Migration[7.2]
  def change
    change_column_default :users, :user_type, from: "developer", to: nil
  end
end

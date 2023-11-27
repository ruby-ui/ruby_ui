class AddPlanToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :plan, :integer, default: 0
  end
end

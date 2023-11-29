class CreateTeamMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :team_members do |t|
      t.string :email
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

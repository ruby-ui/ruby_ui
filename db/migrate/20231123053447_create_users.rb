class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :auth_token
      t.datetime :auth_token_expires_at

      t.timestamps
    end
  end
end

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.text :bio
      t.string :otp_code
      t.datetime :otp_sent_at

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end

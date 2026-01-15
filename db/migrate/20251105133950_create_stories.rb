class CreateStories < ActiveRecord::Migration[8.1]
  def change
    create_table :stories do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, default: "draft"
      t.string :category
      t.references :user, null: false, foreign_key: true
      t.integer :view_count, default: 0

      t.timestamps
    end

    add_index :stories, :status
    add_index :stories, :category
    add_index :stories, :created_at
  end
end

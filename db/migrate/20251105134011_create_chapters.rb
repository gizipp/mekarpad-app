class CreateChapters < ActiveRecord::Migration[8.1]
  def change
    create_table :chapters do |t|
      t.string :title, null: false
      t.text :content
      t.integer :order, null: false
      t.references :story, null: false, foreign_key: true

      t.timestamps
    end

    add_index :chapters, [ :story_id, :order ], unique: true
  end
end

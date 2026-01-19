class CreateReadingLists < ActiveRecord::Migration[8.1]
  def change
    create_table :reading_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :story, null: false, foreign_key: true

      t.timestamps
    end

    add_index :reading_lists, [ :user_id, :story_id ], unique: true
  end
end

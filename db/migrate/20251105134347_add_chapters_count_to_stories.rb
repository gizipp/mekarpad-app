class AddChaptersCountToStories < ActiveRecord::Migration[8.1]
  def change
    add_column :stories, :chapters_count, :integer, default: 0
  end
end

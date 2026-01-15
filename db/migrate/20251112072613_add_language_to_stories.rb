class AddLanguageToStories < ActiveRecord::Migration[8.1]
  def change
    add_column :stories, :language, :string, default: 'en', null: false
  end
end

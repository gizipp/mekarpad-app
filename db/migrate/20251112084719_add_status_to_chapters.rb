class AddStatusToChapters < ActiveRecord::Migration[8.1]
  def change
    add_column :chapters, :status, :string, default: 'draft', null: false
  end
end

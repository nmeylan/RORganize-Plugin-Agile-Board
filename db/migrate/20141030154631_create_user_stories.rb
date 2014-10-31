class CreateUserStories < ActiveRecord::Migration
  def change
    create_table :user_stories do |t|
      t.string :title
      t.text :description
      t.integer :status_id
      t.integer :point_id
      t.integer :position
      t.integer :author_id
      t.integer :epic_id
      t.integer :tracker_id
      t.integer :sprint_id
      t.integer :board_id
      t.integer :category_id

      t.timestamps
    end
  end
end

class InsertIndexes < ActiveRecord::Migration
  def change
    add_index :user_stories, :sprint_id
    add_index :user_stories, :category_id
    add_index :user_stories, :point_id
    add_index :user_stories, :status_id
    add_index :user_stories, :epic_id

    add_index :sprints, :board_id
  end
end

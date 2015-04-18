class AddProjectIdToUserStories < ActiveRecord::Migration
  def change
    add_column :user_stories, :project_id, :integer

    boards = Board.all

    boards.each do |board|
      board.user_stories.update_all(project_id: board.project_id)
    end
  end
end

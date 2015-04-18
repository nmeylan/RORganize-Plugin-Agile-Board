class AddUserStoryScopedIdPerProject < ActiveRecord::Migration
  def change
    add_column :boards, :user_stories_sequence, :integer, null: false, default: 0

    add_column :user_stories, :sequence_id, :integer, null: false, default: 0
    all_boards = Board.all

    all_boards.each do |board|
      stories = board.user_stories
      board.update_column(:user_stories_sequence, stories.count)

      i = 1
      stories.order(:id).each do |story|
        story.update_column(:sequence_id, i)
        i += 1
      end
    end
  end
end

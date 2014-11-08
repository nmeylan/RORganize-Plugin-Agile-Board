class AddIssueUserStory < ActiveRecord::Migration
  def change
    add_column :issues, :user_story_id, :integer
  end
end

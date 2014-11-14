class AddStoriesIssuesCounterCache < ActiveRecord::Migration
  def change
    add_column :user_stories, :issues_count, :integer
  end
end

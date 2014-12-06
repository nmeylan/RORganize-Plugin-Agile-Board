class AddSprintArchive < ActiveRecord::Migration
  def up
    add_column :sprints, :is_archived, :boolean, default: false
  end

  def down
    remove_column :sprints, :is_archived
  end
end

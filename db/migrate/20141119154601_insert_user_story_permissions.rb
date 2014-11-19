class InsertUserStoryPermissions < ActiveRecord::Migration
  def up
    Permission.create(controller: 'User_stories', action: 'change_status', name: 'Change status', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'User_stories', action: 'change_status', name: 'Change status', is_locked: true)
  end
end

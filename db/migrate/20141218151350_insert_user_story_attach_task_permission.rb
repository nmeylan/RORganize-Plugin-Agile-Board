class InsertUserStoryAttachTaskPermission < ActiveRecord::Migration
  def up
    Permission.create(controller: 'User_stories', action: 'attach_tasks', name: 'Attach existing issues', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'User_stories', action: 'attach_tasks', name: 'Attach existing issues')
  end
end

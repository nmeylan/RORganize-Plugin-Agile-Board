class AddStoryCommentWatchPermissions < ActiveRecord::Migration
  def up
    Permission.create(controller: 'User_stories', action: 'comment', name: 'Add Comments (edit and delete own comments)', is_locked: true)
    Permission.create(controller: 'User_stories', action: 'watch', name: 'Watch', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'User_stories', action: 'watch')
    Permission.delete_all(controller: 'User_stories', action: 'comment')
  end
end

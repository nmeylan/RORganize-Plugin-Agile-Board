class InsertAgileBoardPermissions < ActiveRecord::Migration
  def up
    Permission.create(controller: 'Boards', action: 'index', name: 'Access to agile board', is_locked: true)
    Permission.create(controller: 'Boards', action: 'configuration', name: 'Configure agile board', is_locked: true)
    Permission.create(controller: 'Boards', action: 'new', name: 'Create agile board', is_locked: true)
    Permission.create(controller: 'Boards', action: 'destroy', name: 'Delete agile board', is_locked: true)

    Permission.create(controller: 'Epics', action: 'index', name: 'View all epics', is_locked: true)
    Permission.create(controller: 'Epics', action: 'new', name: 'Create epic', is_locked: true)
    Permission.create(controller: 'Epics', action: 'edit', name: 'Update epic', is_locked: true)
    Permission.create(controller: 'Epics', action: 'destroy', name: 'Delete epic', is_locked: true)

    Permission.create(controller: 'Sprints', action: 'new', name: 'Create sprint', is_locked: true)
    Permission.create(controller: 'Sprints', action: 'edit', name: 'Update sprint', is_locked: true)
    Permission.create(controller: 'Sprints', action: 'destroy', name: 'Delete sprint', is_locked: true)

    Permission.create(controller: 'Story_points', action: 'index', name: 'View all points', is_locked: true)
    Permission.create(controller: 'Story_points', action: 'add_points', name: 'Add points', is_locked: true)
    Permission.create(controller: 'Story_points', action: 'edit', name: 'Update/delete point', is_locked: true)

    Permission.create(controller: 'Story_statuses', action: 'index', name: 'View all statuses', is_locked: true)
    Permission.create(controller: 'Story_statuses', action: 'new', name: 'Create status', is_locked: true)
    Permission.create(controller: 'Story_statuses', action: 'edit', name: 'Update status', is_locked: true)
    Permission.create(controller: 'Story_statuses', action: 'destroy', name: 'Destroy status', is_locked: true)
    Permission.create(controller: 'Story_statuses', action: 'change_position', name: 'Change position', is_locked: true)

    Permission.create(controller: 'User_stories', action: 'new', name: 'Create user story', is_locked: true)
    Permission.create(controller: 'User_stories', action: 'show', name: 'View user story', is_locked: true)
    Permission.create(controller: 'User_stories', action: 'edit', name: 'Update user story', is_locked: true)
    Permission.create(controller: 'User_stories', action: 'destroy', name: 'Delete user story', is_locked: true)
    Permission.create(controller: 'User_stories', action: 'new_task', name: 'Add tasks', is_locked: true)
    Permission.create(controller: 'User_stories', action: 'detach_tasks', name: 'Detach tasks', is_locked: true)
    Permission.create(controller: 'User_stories', action: 'change_sprint', name: 'Rank or change sprint', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'Boards')
    Permission.delete_all(controller: 'Epics')
    Permission.delete_all(controller: 'Sprints')
    Permission.delete_all(controller: 'Story_points')
    Permission.delete_all(controller: 'Story_statuses')
    Permission.delete_all(controller: 'User_stories')

  end
end

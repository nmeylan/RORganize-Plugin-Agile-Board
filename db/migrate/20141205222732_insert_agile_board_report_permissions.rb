class InsertAgileBoardReportPermissions < ActiveRecord::Migration
  def up
    Permission.create(controller: 'Sprints', action: 'archive', name: 'Archive sprint', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'Sprints', action: 'archive', name: 'Archive sprint')
  end
end

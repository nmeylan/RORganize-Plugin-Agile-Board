class InsertAgileBoardReportPermissions < ActiveRecord::Migration
  def up
    Permission.create(controller: 'Sprints', action: 'archive', name: 'Archive sprint', is_locked: true)
    Permission.create(controller: 'Agile_board_reports', action: 'index', name: 'View reports', is_locked: true)
  end

  def down
    Permission.delete_all(controller: 'Sprints', action: 'archive', name: 'Archive sprint')
    Permission.delete_all(controller: 'Agile_board_reports', action: 'index', name: 'View reports')
  end
end

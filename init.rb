# Author: Nicolas Meylan
# Date: 30.10.14
# Encoding: UTF-8
# File: init.rb

require 'rorganize'

Rorganize::Managers::PluginManager.register :agile_board do |plugin|
  plugin.author = 'Nicolas Meylan'
  plugin.menu(:project_menu, :agile_board, 'Agile',
              {controller: 'boards', action: 'index'},
              {id: 'menu-boards', after: 'roadmaps', glyph: 'scrum'})

  plugin.add_to_always_enabled_modules([
                                           {controller: 'story_points', action: 'index'},
                                           {controller: 'story_statuses', action: 'index'},
                                           {controller: 'user_stories', action: 'index'},
                                           {controller: 'sprints', action: 'index'},
                                           {controller: 'agile_board_reports', action: 'index'},
                                           {controller: 'epics', action: 'index'}])

  plugin.add_controllers_groups([
                                    Rorganize::Managers::PermissionManager::ControllerGroup.new(
                                        :agile, 'Agile', 'scrum',
                                        %w(story_points story_statuses user_stories sprints agile_board_reports epics boards))
                                ])

  Rorganize::ACTION_ICON.merge!({epic_id: 'sword', point_id: 'coin', sprint_id: 'sprint'})
end

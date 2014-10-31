# Author: Nicolas Meylan
# Date: 30.10.14
# Encoding: UTF-8
# File: init.rb

require 'rorganize'

Rorganize::Managers::PluginManager.register :agile_board do |plugin|
  plugin.author = 'Nicolas Meylan'
  plugin.menu(:project_menu, :agile_board, 'Agile', {controller: 'boards', action: 'index'}, {id: 'menu-boards', after: 'roadmaps', glyph: 'scrum'})

  plugin.add_to_always_enabled_modules([
      {controller: 'story_points', action: 'index'},
      {controller: 'story_statuses', action: 'index'},
      {controller: 'user_stories', action: 'index'},
      {controller: 'sprints', action: 'index'},
      {controller: 'epics', action: 'index'}])

end

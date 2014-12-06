# Author: Nicolas Meylan
# Date: 06.12.14
# Encoding: UTF-8
# File: sprint_health_by_points.rb

require 'agile_board/view_objects/abstract_sprint_health'
class SprintHealthByStories < AbstractSprintHealth
  attr_reader :tasks_count, :tasks_progress
  def initialize(sprint)
    super(sprint, sprint.stories_distribution)
    @tasks_count = sprint.tasks_count
    @tasks_progress = sprint.tasks_progress
  end
end
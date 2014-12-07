# Author: Nicolas Meylan
# Date: 06.12.14
# Encoding: UTF-8
# File: abstract_sprint_health.rb

class SprintHealth
  attr_accessor :sprint, :points_distribution, :stories_distribution, :time_elapsed,
                :time_elapsed_unit, :work_complete, :tasks_count, :tasks_progress,
                :scope_change
  def initialize(sprint)
    @sprint = sprint
    @points_distribution = sprint.points_distribution
    @stories_distribution = sprint.stories_distribution
    @time_elapsed, @time_elapsed_unit = sprint.time_elapsed_calculation
    @work_complete = sprint.work_complete_calculation
    @tasks_count = sprint.tasks_count
    @tasks_progress = sprint.tasks_progress
    @scope_change = sprint.scope_change
  end
end
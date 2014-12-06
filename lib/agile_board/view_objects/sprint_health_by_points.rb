# Author: Nicolas Meylan
# Date: 06.12.14
# Encoding: UTF-8
# File: sprint_health_by_points.rb

require 'agile_board/view_objects/abstract_sprint_health'
class SprintHealthByPoints < AbstractSprintHealth
  attr_reader :time_elapsed, :time_elapsed_unit, :work_complete
  def initialize(sprint)
    super(sprint, sprint.points_distribution)
    @time_elapsed, @time_elapsed_unit = sprint.time_elapsed_calculation
    @work_complete = sprint.work_complete_calculation
  end
end
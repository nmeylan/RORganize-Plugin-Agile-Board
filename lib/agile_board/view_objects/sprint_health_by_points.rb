# Author: Nicolas Meylan
# Date: 06.12.14
# Encoding: UTF-8
# File: sprint_health_by_points.rb

require 'agile_board/view_objects/abstract_sprint_health'
class SprintHealthByPoints < AbstractSprintHealth

  def initialize(sprint)
    super(sprint, sprint.points_distribution)
  end
end
# Author: Nicolas Meylan
# Date: 11.12.14
# Encoding: UTF-8
# File: sprint_burndown.rb

class SprintBurndown
  def initialize(sprint)
    @sprint = sprint
    @burndown_values = @sprint.burndown_values
  end

  def json
    result = {}
    result[:actual] = @burndown_values.map do |date, values|
      {values: {points: values[:sum], stories: values[:stories].to_json}, date: date}
    end
    result[:projected] = [
        {values: {points: @sprint.total_points, stories: {}}, date: @burndown_values.keys.min},
        {values: {points: 0, stories: {}}, date: @burndown_values.keys.max}
    ]
    result.to_json
  end

end
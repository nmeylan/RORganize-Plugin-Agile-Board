# Author: Nicolas Meylan
# Date: 06.12.14
# Encoding: UTF-8
# File: abstract_sprint_health.rb

class AbstractSprintHealth
  attr_accessor :sprint, :distribution
  def initialize(sprint, distribution)
    @sprint = sprint
    @distribution = distribution
  end
end
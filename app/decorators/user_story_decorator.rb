# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: sprint_decorator.rb

class UserStoryDecorator < ApplicationDecorator
  decorates_association :status
  delegate_all
  def display_tracker
    self.tracker.caption
  end

  def display_points
    points = self.points ? self.points : '-'
    h.content_tag :span, points, {class: 'counter total-entries'}
  end

  def display_status
    self.status.display_caption
  end
end
# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: sprint_decorator.rb

class UserStoryDecorator < AgileBoardDecorator
  decorates_association :status
  decorates_association :epic
  delegate_all

  def display_points
    points = self.points ? self.points.value : '-'
    h.content_tag :span, points, {class: 'counter total-entries'}
  end

  def edit_link
    super(context[:project], h.agile_board_plugin::edit_user_story_path(context[:project].slug, model.id), false)
  end

  def delete_link
    super(context[:project], h.agile_board_plugin::user_story_path(context[:project].slug, model.id), false)

  end

  def display_status
    self.status.display_caption
  end

  def display_epic
    self.epic.display_caption if self.epic
  end

  def status_options
    context[:statuses].collect { |status| [status.caption, status.id] }
  end

  def epic_options
    context[:epics].collect { |epic| [epic.caption, epic.id] }
  end

  def category_options
    context[:categories].collect { |category| [category.caption, category.id] }
  end

  def tracker_options
    context[:trackers].collect { |tracker| [tracker.caption, tracker.id] }
  end

  def context_sprint
    context[:sprint_id]
  end

  def point_options
    context[:points].collect { |point| [point.caption, point.id] }
  end
end
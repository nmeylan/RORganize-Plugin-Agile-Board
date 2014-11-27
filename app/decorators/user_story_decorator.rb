# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: sprint_decorator.rb

class UserStoryDecorator < AgileBoardDecorator
  include UserStoryDecoratorLink
  decorates_association :sprint
  decorates_association :status
  decorates_association :epic
  decorates_association :issues
  delegate_all

  def display_points
    points = self.points ? self.points.value : '-'
    h.content_tag :span, points, {class: 'counter total-entries story-points tooltipped tooltipped-s', label: h.t(:tooltip_points)}

  end

  def display_status
    self.status.display_caption
  end

  def display_epic
    self.epic.display_caption if self.epic
  end

  def display_tracker
    self.tracker.caption
  end

  def display_id
    "##{self.id}"
  end

  def display_tracker_id
    h.content_tag :span, "#{self.display_tracker} #{self.display_id}", class: 'story-tracker'
  end

  def display_issues_counter
    count = model.issues_count ? model.issues_count : '0'
    h.content_tag :span, {class: 'counter total-entries story-issues-count tooltipped tooltipped-s', label: h.t(:label_tasks)} do
      h.safe_concat count
    end
  end

  def display_category
    display_info_square(model.category, 'tag', false)
  end

  def display_sprint_dates
    self.sprint.display_dates if self.sprint
  end

  def display_sprint
    model.get_sprint.caption
  end

  def display_tasks
    h.story_tasks_list(self)
  end

  def display_version
    self.sprint ? display_info_square(model.sprint.version, 'milestone') : '-'
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
    context[:trackers].sort_by(&:position).collect { |tracker| [tracker.caption, tracker.id] }
  end

  def context_sprint
    context[:sprint_id]
  end

  def point_options
    context[:points].collect { |point| [point.caption, point.id] }
  end

  def display_all_assigned
    self.issues.map(&:display_assigned_to_avatar).compact.uniq.join.html_safe
  end

  def total_progress
    self.issues.inject(0) { |sum, issue| sum + (issue.done ? issue.done : 0) }
  end

  def total_progress_bar
    h.mini_progress_bar_tag(self.total_progress, 'width-100')
  end

  def display_object_type(project)
    h.safe_concat h.content_tag :b, "#{h.t(:label_user_story)} "
    "<a href='/projects/#{project.slug}/agile_board/user_stories/#{self.id}'>#{resized_caption}</a>".html_safe
  end




end
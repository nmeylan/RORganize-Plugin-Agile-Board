# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: sprint_decorator.rb

# WARNING : Here I use raw html instead of content tag due to performance issues.
# User raw html reduce by 100% the render time.
class UserStoryDecorator < AgileBoardDecorator
  include UserStoryDecoratorLink
  decorates_association :sprint
  decorates_association :issues
  delegate_all
  POINTS_LABEL = h.t(:tooltip_points)
  TASK_LABEL = h.t(:label_tasks)

  def tracker_caption
    @tracker_caption ||= object.tracker.caption.freeze if model.tracker
  end

  def epic_caption
    @epic_caption ||= model.epic ? model.epic.caption.freeze : nil
  end

  def category_caption
    @category_caption ||= model.category ? model.category.caption.freeze : nil
  end

  def status_caption
    @status_caption ||= model.status ? model.status.caption.freeze : nil
  end

  def display_points
    points = self.points ? self.points.value : '-'.freeze
    "<span class='counter total-entries story-points tooltipped tooltipped-s' label='#{POINTS_LABEL}'>#{points}</span>".html_safe
  end

  def display_status
    "<span class='issue-status filter-link' data-filtertype='status' style='#{h.style_background_color(model.status.color)}'>
      #{self.status_caption}
    </span>".html_safe
  end

  def display_epic
    "<span class='info-square epic-caption filter-link' data-filtertype='epic' style='#{h.style_background_color(model.epic.color)}'>
          <span class='octicon octicon-sword'></span>
          #{self.epic_caption}
    </span>".html_safe if self.epic_caption
  end

  def display_tracker
    self.tracker_caption ||= model.tracker.caption
  end

  def display_id
    "##{self.sequence_id}".freeze
  end

  def display_tracker_id
    "<span class='story-tracker filter-link' data-filtertype='tracker'>#{self.display_tracker} #{self.display_id}</span>".html_safe
  end

  def display_issues_counter
    count = model.issues_count ? model.issues_count : '0'.freeze
    "<span class='counter total-entries story-issues-count tooltipped tooltipped-s' label='#{TASK_LABEL}'>#{count}</span>".html_safe
  end

  def display_category
    "<span class='info-square filter-link' data-filtertype='category'><span class='octicon octicon-tag'></span>#{self.category_caption}</span>".html_safe if self.category_caption
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
    self.sprint ? display_info_square(model.sprint.version, 'milestone'.freeze) : '-'.freeze
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

  def points_options
    context[:points].collect { |point| [point.caption, point.id] }
  end

  def display_all_assigned
    self.issues.map(&:display_assigned_to_avatar).compact.uniq.join.html_safe
  end

  def total_progress
    self.issues.size > 0 ? (self.issues.inject(0) { |sum, issue| sum + (issue.done ? issue.done : 0) } / self.issues.size) : 100
  end

  def total_progress_bar
    h.mini_progress_bar_tag(self.total_progress, 'width-100'.freeze)
  end

  def display_object_type(project)
    h.concat h.content_tag :b, "#{h.t(:label_user_story)} "
    "<a href='/projects/#{project.slug}/agile_board/user_stories/#{self.sequence_id}'>#{resized_caption}</a>".html_safe
  end


end
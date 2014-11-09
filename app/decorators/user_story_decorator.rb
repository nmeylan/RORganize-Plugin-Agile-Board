# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: sprint_decorator.rb

class UserStoryDecorator < AgileBoardDecorator
  attr_accessor :show_link
  decorates_association :sprint
  decorates_association :status
  decorates_association :epic
  decorates_association :issues
  delegate_all

  def display_points
    points = self.points ? self.points.value : '-'
    h.content_tag :span, points, {class: 'counter total-entries story-points'}
  end

  def edit_link(button = false, path_params = {})
    if User.current.allowed_to?(:edit, 'user_stories', context[:project])
      link_to_edit_story(button, path_params)
    end
  end

  def link_to_edit_story(button, path_params)
    h.link_to(h.glyph(h.t(:link_edit), 'pencil'),
              h.agile_board_plugin::edit_user_story_path(context[:project].slug, model.id, path_params),
              {remote: true, method: :get, class: "#{'button' if button}"})
  end

  def delete_link(button = false, path_params = {})
    if User.current.allowed_to?(:destroy, 'user_stories', context[:project])
      link_to_delete_story(button, path_params)
    end
  end

  def link_to_delete_story(button, path_params)
    h.link_to h.glyph(h.t(:link_delete), 'trashcan'),
              h.agile_board_plugin::user_story_path(context[:project].slug, model.id, path_params),
              {remote: true, method: :delete, class: "danger danger-dropdown #{'button' if button}", 'data-confirm' => h.t(:text_delete_item)}
  end

  def fast_show_link(caption)
    if User.current.allowed_to?(:show, 'user_stories', context[:project])
      h.fast_story_show_link(context[:project], model.id, caption).html_safe
    end
  end

  def show_link(caption)
    if User.current.allowed_to?(:show, 'user_stories', context[:project])
      h.link_to(caption, h.agile_board_plugin::user_story_path(context[:project].slug, model.id))
    end
  end

  def new_task_link
    h.link_to_with_permissions(h.glyph(h.t(:link_new_task), 'plus'),
                               h.agile_board_plugin::user_story_new_task_path(context[:project].slug, model.id), context[:project], nil, {class: 'button', remote: true})
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
    context[:trackers].collect { |tracker| [tracker.caption, tracker.id] }
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
    self.issues.inject(0) { |sum, issue| sum + issue.done }
  end

  def total_progress_bar
    h.mini_progress_bar_tag(self.total_progress, 'width-100')
  end
end
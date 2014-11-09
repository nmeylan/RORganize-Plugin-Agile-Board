# Author: Nicolas Meylan
# Date: 08.11.14
# Encoding: UTF-8
# File: user_story_tasks.rb

module UserStoryTasksHelper
  def story_task_editor_overlay(model = nil, path = nil, method = nil)
    agile_board_overlay_editor('story-task-editor-overlay', t(:link_new_task), model) do
      story_task_form(model, path, method)
    end
  end

  def story_task_form(model, path, method)
    overlay_form(model, path, method) do |f|
      safe_concat f.hidden_field(:tracker_id, value: model.tracker_id)
      safe_concat f.hidden_field(:category_id, value: model.category_id)
      safe_concat f.hidden_field(:status_id, value: model.status_id)
      safe_concat f.hidden_field(:version_id, value: model.version_id)
      safe_concat story_task_form_assigned_field(f, model)
      safe_concat required_form_text_field(f, :subject, t(:field_subject), {size: 80})
      safe_concat agile_board_form_description_field(f)
    end
  end


  def story_task_form_assigned_field(f, model)
    agile_board_select_field(f, :assigned_to, t(:field_assigned_to)) do
      f.select :assigned_to_id, @members.collect { |member| [member.user.name, member.user.id] },
               {include_blank: true}, {class: 'chzn-select-deselect cbb-medium search'}
    end
  end

  def story_tasks_list(model)
    if model.issues.any?
      content_tag :div, class: 'box' do
        content_tag :ul, {class: "sortable fancy-list fancy-list-mini story-tasks-list"} do
          render_tasks(model)
        end
      end
    else
      no_data(t(:text_no_tasks), 'issue-opened', true)
    end
  end

  def render_tasks(model)
    model.issues.collect do |issue|
      render_task(issue)
    end.join.html_safe
  end

  def render_task(issue)
    content_tag :li, class: "fancy-list-item story", id: "task-#{issue.id}" do
      safe_concat render_story_task_left_content(issue)
      safe_concat render_story_task_right_content(issue)
      safe_concat clear_both
    end
  end

  def render_story_task_left_content(issue)
    content_tag :span, class: 'story-task-left-content' do
      concat_span_tag issue.tracker_str, class: 'story-task-tracker'
      safe_concat issue.show_link
    end
  end

  def render_story_task_right_content(issue)
    content_tag :span, class: 'fancy-list right-content-list' do
      safe_concat issue.display_assigned_to_avatar
      safe_concat issue.display_version if issue.version_id
      safe_concat issue.display_category if issue.category_id
      safe_concat issue.display_status
      safe_concat progress_bar_tag(issue.done)
    end
  end

  def render_story_trash_tasks(model)
    content_tag :div, {id: 'trash-story-tasks', class: 'box'} do
      safe_concat content_tag :ul, nil, class: 'fancy-list fancy-list-mini story-tasks-list sortable'
      safe_concat render_story_trash_tasks_placeholder(model)
    end
  end

  def render_story_trash_tasks_placeholder(model)
    content_tag :div, {class: 'trash-placeholder'} do
      safe_concat content_tag :p, t(:text_trash_task_placeholder)
      safe_concat model.detach_tasks_link
    end
  end

end
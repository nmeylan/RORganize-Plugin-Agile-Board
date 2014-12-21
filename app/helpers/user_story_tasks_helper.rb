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

  def story_attach_tasks_overlay
    overlay_tag('story-attach-task-overlay') do
      concat content_tag :h1, t(:title_attach_task)
      concat story_attach_tasks_form
    end
  end

  def story_attach_tasks_form
    form_tag agile_board_plugin::user_story_attach_tasks_path(@project.slug, @user_story_decorator.id), {class: 'form'} do
      concat text_area_tag 'tasks', nil, {placeholder: '#45531 #45438', rows: 12, id: 'story-attach-tasks-textarea'}
      concat submit_tag t(:button_submit)
    end
  end

  def story_task_form(model, path, method)
    overlay_form(model, path, method) do |f|
      concat f.hidden_field(:tracker_id, value: model.tracker_id)
      concat f.hidden_field(:category_id, value: model.category_id)
      concat f.hidden_field(:status_id, value: model.status_id)
      concat f.hidden_field(:version_id, value: model.version_id)
      concat story_task_form_assigned_field(f, model)
      concat required_form_text_field(f, :subject, t(:field_subject), {size: 80})
      concat agile_board_form_description_field(f)
    end
  end


  def story_task_form_assigned_field(f, model)
    agile_board_select_field(f, :assigned_to, t(:field_assigned_to), model) do
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
      concat render_story_task_left_content(issue)
      concat render_story_task_right_content(issue)
      concat clear_both
    end
  end

  def render_story_task_left_content(issue)
    content_tag :span, class: 'story-task-left-content' do
      concat_span_tag "#{issue.tracker_str} ##{issue.id}", class: 'story-task-tracker'
      concat issue.show_link
    end
  end

  def render_story_task_right_content(issue)
    content_tag :span, class: 'fancy-list right-content-list' do
      concat issue.display_assigned_to_avatar
      concat issue.display_version if issue.version_id
      concat issue.display_category if issue.category_id
      concat issue.display_status
      concat progress_bar_tag(issue.done)
    end
  end

  def render_story_trash_tasks(model)
    if model.issues.any?
      content_tag :div, {id: 'trash-story-tasks', class: 'box'} do
        concat content_tag :ul, nil, class: 'fancy-list fancy-list-mini story-tasks-list sortable'
        concat render_story_trash_tasks_placeholder(model)
      end
    end
  end

  def render_story_trash_tasks_placeholder(model)
    content_tag :div, {class: 'trash-placeholder'} do
      concat content_tag :p, t(:text_trash_task_placeholder)
      concat model.detach_tasks_link
    end
  end

end
module SprintsHelper
  include UserStoriesHelper
  include AgileBoardHelper

  def sprints_content(sprints)
    concat render_sprints(sprints)
    concat editor_overlay('sprint', t(:link_new_sprint))
    concat editor_overlay('story', t(:link_new_story))
  end

  def render_sprints(sprints)
    sprints_options = {class: "sprints #{'splitcontentleft' if split_content?}", id: 'sprints-list'}
    content_tag :div, sprints_options do
      if sprints.any?
        sprints.collect { |sprint| render_sprint(sprint) }.join.html_safe
      else
        render_no_sprints
      end
    end
  end

  def render_no_sprints
    content_tag :div, {class: "box"} do
      concat box_header_tag t(:label_agile_board_sprints), 'header header-left', &Proc.new {
        @board_decorator.new_sprint
      }
      concat no_data(t(:text_no_sprints), 'sprint', true)
    end
  end

  def render_sprint(sprint, class_css = '')
    content_tag :div, {class: "box sprint #{class_css}", id: "sprint-#{sprint.id}"} do
      concat render_sprint_header(sprint, class_css)
      concat render_sprint_content(sprint, class_css)
    end
  end

  def render_sprint_header(sprint, class_css = 'sprint')
    content_tag :div, class: 'header header-left' do
      concat sprint_header_left_content(sprint)
      concat sprint_header_right_content(class_css, sprint)
    end
  end

  def sprint_header_left_content(sprint)
    content_tag :span, class: 'sprint-header-left' do
      concat link_to glyph('', 'chevron-down'), '#', {id: "content-sprint-#{sprint.id}", class: 'icon-expanded sprint-expand'}
      concat content_tag :h2, sprint.show_link
      concat sprint.display_dates
      concat sprint.display_version
    end
  end

  def sprint_header_right_content(class_css, sprint)
    content_tag :div, class: 'right' do
      concat sprint.display_count_stories
      concat sprint.display_count_points
      sprint_extra_button(class_css, sprint)
    end
  end

  def sprint_extra_button(class_css, sprint)
    if is_backlog?(class_css)
      concat sprint.new_story
      concat @board_decorator.new_sprint
    else
      concat sprint_dropwdown(sprint)
    end
  end

  def sprint_dropwdown(sprint)
    actions = [sprint.new_story(false), sprint.edit_link, sprint.archive_link, sprint.restore_link,sprint.delete_link].compact
    if actions.any?
      dropdown_tag do
        actions.collect{|action| dropdown_row action}.join.html_safe
      end
    end
  end

  def is_backlog?(class_css)
    class_css.split(' '.freeze).include?('backlog')
  end

  def render_sprint_content(sprint, class_css = 'sprint')
    content_tag :div, class: "sprint content content-sprint-#{sprint.id}" do
      concat render_sprint_body(sprint)
      unless sprint.stories.any?
        concat no_data(t(:text_no_stories), 'tasks', true)
      end
    end
  end

  def render_sprint_body(sprint)
    sortable = 'sortable' if User.current.allowed_to?('change_sprint', 'User_stories', @project)
    content_tag :ul, {class: "fancy-list fancy-list-mini stories-list #{sortable}"} do
      sprint.sorted_stories.collect do |story|
        render_story(story)
      end.join.html_safe
    end
  end

  def sprint_form(model, path, method)
    overlay_form(model, path, method) do |f|
      concat sprint_form_version_field(model, f)
      concat required_form_text_field(f, :name, t(:field_name))
      concat sprint_date_field(f, :start_date, t(:field_start_date))
      concat sprint_date_field(f, :end_date, t(:field_target_date), false)
    end
  end

  def sprint_form_version_field(model, f)
    agile_board_select_field(f, :version_id, t(:field_version), model) do
      select_tag_versions(@project.versions, 'sprint_version_id', 'sprint[version_id]', model.version_id,
                          {'data-link' => agile_board_plugin::generate_sprint_name_path(@project.slug)})
    end
  end


  def sprint_date_field(f, field, text, required = true)
    content_tag :p do
      concat required ? required_form_label(f, field, text) : f.label(field, text)
      concat f.date_field field, size: 6
    end
  end
end

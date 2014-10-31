module SprintsHelper
  include UserStoriesHelper

  def render_sprints(sprints)
    content_tag :div, class: 'sprints splitcontentleft' do
      if sprints.any?
        sprints.collect { |sprint| render_sprint(sprint) }.join.html_safe
      else
        render_no_sprints
      end
    end
  end

  def render_no_sprints
    content_tag :div, {class: "box"} do
      safe_concat box_header_tag t(:label_agile_board_sprints), 'header header-left', &Proc.new {
        @board_decorator.new_sprint
      }
      safe_concat no_data(t(:text_no_sprints), 'sprint', true)
    end
  end

  def render_sprint(sprint, class_css = 'sprint')
    content_tag :div, {class: "box #{class_css}", id: "sprint-#{sprint.id}"} do
      safe_concat render_sprint_header(sprint, class_css)
      safe_concat render_sprint_content(sprint, class_css)
    end
  end

  def render_sprint_header(sprint, class_css = 'sprint')
    content_tag :div, class: 'header header-left' do
      safe_concat content_tag :h2, sprint.caption
      safe_concat content_tag :span, "#{sprint.stories.size} stories", {class: 'counter total-entries'}
      sprint_header_right_content(class_css, sprint)
    end
  end

  def sprint_header_right_content(class_css, sprint)
    safe_concat content_tag :div, class: 'right', &Proc.new {
      safe_concat sprint.new_story
      sprint_extra_button(class_css, sprint)
    }
  end

  def sprint_extra_button(class_css, sprint)
    if is_backlog?(class_css)
      safe_concat @board_decorator.new_sprint
    else
      safe_concat sprint.edit_link
      safe_concat sprint.delete_link
    end
  end

  def is_backlog?(class_css)
    class_css.split(' ').include?('backlog')
  end

  def render_sprint_content(sprint, class_css = 'sprint')
    safe_concat render_sprint_body(sprint)
    unless sprint.stories.any?
       no_data(t(:text_no_stories), 'tasks', true)
    end
  end

  def render_sprint_body(sprint)
    content_tag :ul, {class: "fancy-list fancy-list-mini stories-list sortable #{'no-stories' if sprint.stories.empty?}"} do
      sprint.stories.collect do |story|
        render_story(story)
      end.join.html_safe
    end
  end
end

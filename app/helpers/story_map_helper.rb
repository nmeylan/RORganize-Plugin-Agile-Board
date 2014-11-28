# Author: Nicolas Meylan
# Date: 13.11.14
# Encoding: UTF-8
# File: story_map_helper.rb

module StoryMapHelper
  def story_map_render(statuses, sprints, stories_hash)
    content_tag :div, class: 'story-map' do
      number_cols = statuses.size
      if sprints.any?
        stories_hash.collect do |sprint_id, status_stories_hash|
          safe_concat story_map_render_sprint_map(status_stories_hash, number_cols, sprint_id, sprints, statuses)
        end.join.html_safe
      else
        no_data
      end
    end
  end

  def story_map_render_sprint_map(status_stories_hash, number_cols, sprint_id, sprints, statuses)
    sprint = sprints.detect { |sprint| sprint.id.eql?(sprint_id) }
    content_tag :div, id: "sprint-#{sprint_id}", class: 'sprint' do
      safe_concat story_map_sprint_header(sprint, status_stories_hash, statuses)
      safe_concat story_map_render_sprint_content_map(status_stories_hash, number_cols, statuses)
      safe_concat clear_both
    end
  end

  def story_map_sprint_header(sprint, status_stories_hash, statuses)
    content_tag :div, class: 'story-map-sprint-header' do
      safe_concat content_tag :h1, sprint.name, class: 'story-map-sprint-name sprint'
      safe_concat story_map_sprint_header_info(sprint, status_stories_hash, statuses) unless sprint.is_backlog?
    end
  end

  def story_map_sprint_header_info(sprint, status_stories_hash, statuses)
    content_tag :div, class: 'story-map-sprint-header-info' do
      safe_concat sprint.display_info_text
      safe_concat sprint.display_status_bar(status_stories_hash, statuses)
    end
  end

  def story_map_render_sprint_content_map(status_stories_hash, number_cols, statuses)
    statuses.collect do |status|
      story_map_column_render(status, status_stories_hash[status.caption], number_cols)
    end.join.html_safe
  end

  def story_map_column_render(status, stories, number_cols)
    content_tag :div, {class: 'story-map-column status', id: "status-#{status.id}", style: "width:#{100 / number_cols}%"} do
      safe_concat story_map_column_header(status, stories.size)
      safe_concat content_tag :div, nil, class: 'story-map-column status-color', style: "background-color:#{status.color}"
      safe_concat story_map_stories_render(stories)
    end
  end

  def story_map_column_header(status, stories_count)
    content_tag :div, {class: 'story-map-column-header'} do
      safe_concat "#{status.caption} "
      concat_span_tag stories_count, class: 'status-stories-counter counter total-entries tooltipped tooltipped-s', label: t(:label_stories)
    end
  end

  def story_map_stories_render(stories)
    sortable = 'sortable' if User.current.allowed_to?('change_status', 'User_stories', @project)
    content_tag :ul, class: "#{sortable} story-map-stories" do
      stories.collect do |story|
        story_map_story_render(story)
      end.join.html_safe
    end
  end

  def story_map_story_render(story)
    content_tag :li, {class: 'story', id: "story-#{story.id}", 'data-link' => story.change_status_link} do
      safe_concat story_map_story_header_render(story)
      concat_span_tag story.show_link(story.resized_caption(200), true), class: 'story-title'
    end
  end

  def story_map_story_header_render(story)
    content_tag :div, class: 'story-header' do
      safe_concat story_map_story_header_left(story)
      safe_concat story_map_story_header_right(story)
      safe_concat clear_both
    end
  end

  def story_map_story_header_right(story)
    content_tag :div, {class: 'story-right-content'} do
      safe_concat story.display_issues_counter
      concat_span_tag story.display_points, class: 'story-points'
    end
  end

  def story_map_story_header_left(story)
    content_tag :div, {class: 'story-left-content'} do
      story.display_tracker_id
    end
  end
end
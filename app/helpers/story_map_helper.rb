# Author: Nicolas Meylan
# Date: 13.11.14
# Encoding: UTF-8
# File: story_map_helper.rb

module StoryMapHelper
  def story_map_render(statuses, stories_hash)
    content_tag :div, class: 'story-map' do
      number_cols = stories_hash.values.size
      statuses.each do |status|
        safe_concat story_map_column_render(status, stories_hash[status.caption], number_cols)
      end
    end
  end

  def story_map_column_render(status, stories, number_cols)
    status_id_str = status.caption.downcase.tr(' ', '')
    content_tag :div, {class: 'story-map-column', id: "status-#{status_id_str}", style: "width:#{100 / number_cols}%"} do
      safe_concat content_tag :div, status.caption, {class: 'story-map-column-header'}
      safe_concat story_map_stories_render(stories)
    end
  end

  def story_map_stories_render(stories)
    content_tag :div, class: 'story-map-stories' do
      stories.collect do |story|
        story_map_story_render(story)
      end.join.html_safe
    end
  end

  def story_map_story_render(story)
    content_tag :div, {class: 'story', id: "story-#{story.id}"} do
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
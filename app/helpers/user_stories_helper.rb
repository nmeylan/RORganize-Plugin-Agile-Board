module UserStoriesHelper
  def render_story(story)
    content_tag :li, class: "fancy-list-item story", id: "story-#{story.id}" do
      safe_concat render_story_left_content(story)
      safe_concat render_story_right_content(story)
    end
  end

  def render_story_left_content(story)
    content_tag :span, class: 'story-left-content' do
      concat_span_tag story.display_tracker
      concat_span_tag story.caption
    end
  end

  def render_story_right_content(story)
    content_tag :span, class: 'fancy-list right-content-list' do
      concat_span_tag story.display_status
      concat_span_tag story.display_points
    end
  end
end

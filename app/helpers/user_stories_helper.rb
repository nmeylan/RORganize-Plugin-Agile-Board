module UserStoriesHelper
  include AgileBoardHelper
  include UserStoryTasksHelper
  include CommentsHelper

  def render_story(story)
    story_options = {class: "fancy-list-item story", id: "story-#{story.id}"}
    story_options['data-link'.freeze] = story.change_sprint_link
    story_options['style'.freeze] = 'display:block'.freeze
    story_options.merge!(story.search_data_hash)
    content_tag :li, story_options do
      safe_concat render_story_left_content(story)
      safe_concat render_story_right_content(story)
      safe_concat clear_both
    end
  end

  def render_story_left_content(story)
    content_tag :span, class: 'story-left-content' do
      safe_concat story.display_tracker_id
      concat_span_tag story.show_link(story.caption, true), class: 'story-title'
    end
  end

  def render_story_right_content(story)
    content_tag :span, class: 'fancy-list right-content-list' do
      story_detail_content(story) if unified_content?
      safe_concat story.display_status
      safe_concat story.display_issues_counter if unified_content?
      safe_concat story.display_points
      safe_concat story_right_dropdown(story) if unified_content?
    end
  end

  def story_right_dropdown(story)
    actions = [story.edit_link(false, {}, true), story.delete_link(false, {}, true)].compact
    if actions.any?
      dropdown_tag do
        actions.collect { |action| dropdown_row  action }.join.html_safe
      end
    end
  end

  def story_detail_content(story)
    safe_concat story.display_category
    safe_concat story.display_epic
  end


  def story_form(model, path, method)
    overlay_form(model, path, method) do |f|
      safe_concat f.hidden_field(:sprint_id, value: model.sprint_id)
      safe_concat story_form_left_content(f, model)
      safe_concat story_form_right_content(f, model)
      safe_concat clear_both
      safe_concat required_form_text_field(f, :title, t(:field_title), {size: 80, maxLength: 255})
      safe_concat agile_board_form_description_field(f)
    end
  end

  def story_form_left_content(f, model)
    content_tag :div, class: 'splitcontentleft' do
      safe_concat story_form_status_field(f, model)
      safe_concat story_form_tracker_field(f, model)
    end
  end

  def story_form_right_content(f, model)
    content_tag :div, class: 'splitcontentright' do
      safe_concat story_form_point_field(f, model)
      safe_concat story_form_epic_field(f, model)
      safe_concat story_form_category_field(f, model)
    end
  end

  def story_form_status_field(f, model)
    agile_board_select_field(f, :status, t(:field_status), model, true)
  end

  def story_form_epic_field(f, model)
    agile_board_select_field(f, :epic, t(:field_epic), model)
  end

  def story_form_category_field(f, model)
    agile_board_select_field(f, :category, t(:field_category), model)
  end

  def story_form_tracker_field(f, model)
    agile_board_select_field(f, :tracker, t(:field_tracker), model, true)
  end

  def story_form_point_field(f, model)
    agile_board_select_field(f, :point, t(:link_story_points), model)
  end

  def caption_sized
    unified_content? ? 150 : 50
  end
end

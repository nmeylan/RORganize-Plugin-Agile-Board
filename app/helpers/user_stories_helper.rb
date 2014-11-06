module UserStoriesHelper
  include AgileBoardHelper
  def render_story(story)
    content_tag :li, class: "fancy-list-item story", id: "story-#{story.id}" do
      safe_concat render_story_left_content(story)
      safe_concat render_story_right_content(story)
      safe_concat clear_both
    end
  end

  def render_story_left_content(story)
    content_tag :span, class: 'story-left-content' do
      concat_span_tag story.display_tracker, class: 'story-tracker'
      concat_span_tag story.show_link(story.resized_caption(caption_sized)), class: 'story-title'
    end
  end

  def render_story_right_content(story)
    content_tag :span, class: 'fancy-list right-content-list' do
      safe_concat story.display_category if unified_content?
      safe_concat story.display_epic
      safe_concat story.display_status
      safe_concat story.display_points
      safe_concat story_right_dropdown(story)
    end
  end

  def story_right_dropdown(story)
    dropdown_tag do
      safe_concat dropdown_row story.edit_link
      safe_concat dropdown_row story.delete_link
    end
  end

  def story_editor_overlay(model = nil, path = nil, method = nil)
    agile_board_overlay_editor('story-editor-overlay', t(:link_new_story), model) do
      story_form(model, path, method)
    end
  end

  def story_form(model, path, method)
    overlay_form(model, path, method) do |f|
      safe_concat f.hidden_field(:sprint_id, value: model.sprint_id)
      safe_concat story_form_left_content(f, model)
      safe_concat story_form_right_content(f, model)
      safe_concat clear_both
      safe_concat required_form_text_field(f, :title, t(:field_title), {size: 80})
      safe_concat story_form_description_field(f)
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
    agile_board_select_field(f, :status, t(:field_status), true) do
      f.select :status_id, model.status_options, {include_blank: false}, {class: 'chzn-select  cbb-medium search'}
    end
  end

  def story_form_description_field(f)
    content_tag :p do
      safe_concat f.label :description, t(:field_description)
      safe_concat f.text_area :description, {class: 'fancyEditor', rows: 12}
    end
  end

  def story_form_epic_field(f, model)
    agile_board_select_field(f, :epic, t(:field_epic)) do
      f.select :epic_id, model.epic_options, {include_blank: true}, {class: 'chzn-select-deselect  cbb-medium search'}
    end
  end

  def story_form_category_field(f, model)
    agile_board_select_field(f, :category, t(:field_category)) do
      f.select :category_id, model.category_options, {include_blank: true}, {class: 'chzn-select-deselect  cbb-medium search'}
    end
  end

  def story_form_tracker_field(f, model)
    agile_board_select_field(f, :tracker, t(:field_tracker), true) do
      f.select :tracker_id, model.tracker_options, {include_blank: false}, {class: 'chzn-select  cbb-medium search'}
    end
  end

  def story_form_point_field(f, model)
    agile_board_select_field(f, :point, t(:link_story_points)) do
      f.select :point_id, model.point_options, {include_blank: true}, {class: 'chzn-select-deselect  cbb-medium search'}
    end
  end

  def caption_sized
    unified_content? ? 150 : 50
  end
end

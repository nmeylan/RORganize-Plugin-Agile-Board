module UserStoriesHelper
  include AgileBoardHelper
  include UserStoryTasksHelper
  include CommentsHelper

  # Render a user story. Didn't use content_tag due to performance issue,
  # raw html is ugly but faster. =(
  # @param [UserStoryDecorator] story
  def render_story(story)
    "<li  class='fancy-list-item story' id='story-#{story.id}' data-link='#{story.change_sprint_link}'
          style='display:block' #{story.search_data_string}'>
      #{render_story_left_content(story)}
      #{render_story_right_content(story)}
      <div style='clear:both'></div>
    </li>".html_safe
  end

  def render_story_left_content(story)
    content_tag :span, class: 'story-left-content' do
      concat story.display_tracker_id
      concat_span_tag story.show_link(story.caption, true), class: 'story-title'
    end
  end

  def render_story_right_content(story)
    content_tag :span, class: 'fancy-list right-content-list' do
      story_detail_content(story) if unified_content?
      concat story.display_status
      concat story.display_issues_counter if unified_content?
      concat story.display_points
      concat story_right_dropdown(story) if unified_content? && !story.archived?
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
    concat story.display_category
    concat story.display_epic
  end


  def story_form(model, path, method)
    overlay_form(model, path, method) do |f|
      concat f.hidden_field(:sprint_id, value: model.sprint_id)
      concat story_form_left_content(f, model)
      concat story_form_right_content(f, model)
      concat clear_both
      concat f.input :title, my_wrapper_html: {class: "col-sm-10"}, label_html: {class: "col-sm-2"}, input_html: {maxLength: 255}
      concat f.input :description, as: :text, my_wrapper_html: {class: "col-sm-10"}, label_html: {class: "col-sm-2"}, input_html: {class: 'fancyEditor', rows: 10}
    end
  end

  def story_form_left_content(f, model)
    content_tag :div, class: 'col-sm-6' do
      concat story_form_status_field(f, model)
      concat story_form_tracker_field(f, model)
    end
  end

  def story_form_right_content(f, model)
    content_tag :div, class: 'col-sm-6' do
      concat story_form_point_field(f, model)
      concat story_form_epic_field(f, model)
      concat story_form_category_field(f, model)
    end
  end

  def story_form_status_field(f, model)
    agile_board_select_field(f, :status, model, true)
  end

  def story_form_epic_field(f, model)
    agile_board_select_field(f, :epic, model)
  end

  def story_form_category_field(f, model)
    agile_board_select_field(f, :category, model)
  end

  def story_form_tracker_field(f, model)
    agile_board_select_field(f, :tracker, model, true)
  end

  def story_form_point_field(f, model)
    agile_board_select_field(f, :points, model)
  end

  def caption_sized
    unified_content? ? 150 : 50
  end
end

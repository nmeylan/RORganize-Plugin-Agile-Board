module StoryStatusesHelper
  include AgileBoardHelper
  def statuses_content
    content_tag :div, {id: 'statuses-tab', class: 'box', style: 'display:none'} do
      safe_concat statuses_list_header
      safe_concat statuses_list
    end
  end

  def statuses_list_header
    box_header_tag t(:field_name), 'header header-left' do
      @board_decorator.new_status_link
    end
  end

  def statuses_list
    path = agile_board_plugin::story_status_change_position_path(@project.slug, '-1')
    content_tag :ul, {class: "fancy-list fancy-list-mini story-statuses-list sortable", 'data-link' => path} do
      @board_decorator.sorted_statuses.collect do |status|
        statuses_list_row(status)
      end.join.html_safe
    end
  end

  def statuses_list_row(status)
    content_tag :li, class: "fancy-list-item status", id: "status-#{status.id}" do
      safe_concat content_tag :span, status.display_caption
      safe_concat statuses_list_button(status)
    end
  end

  def statuses_list_button(status)
    content_tag :div, class: 'fancy-list right-content-list' do
      safe_concat status.edit_link(@project)
      safe_concat status.delete_link(@project)
    end
  end

  def status_form(model, path, method)
    overlay_form(model, path, method) do |f|
      safe_concat status_form_field(f, model)
      safe_concat status_form_color_field(f, model)
    end
  end

  def status_form_field(f, model)
    content_tag :p do
      safe_concat required_form_label(f, :name,  t(:field_name))
      safe_concat f.text_field :name, value: model.caption
    end
  end

  def status_form_color_field(f, model)
    content_tag :p do
      safe_concat f.label :color, t(:label_color)
      safe_concat color_field_tag f, :color
    end
  end

  def status_editor_overlay(model = nil, path = nil, method = nil)
    overlay_tag('status-editor-overlay') do
      status_form(model, path, method) if model
    end
  end

end

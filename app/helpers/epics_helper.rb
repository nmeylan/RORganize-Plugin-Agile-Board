module EpicsHelper
  def epics_content
    content_tag :div, {id: 'epics-tab', class: 'box', style: 'display:none'} do
      safe_concat epics_list_header
      safe_concat epics_list
      safe_concat epic_editor_overlay
    end
  end

  def epics_list_header
    box_header_tag t(:field_name), 'header header-left' do
      @board_decorator.new_epic_link
    end
  end
  
  def epics_list
    content_tag :ul, {class: "fancy-list fancy-list-mini epics-list"} do
      @board_decorator.decorated_epics.collect do |epic|
        epics_list_row(epic)
      end.join.html_safe
    end
  end

  def epics_list_row(epic)
    content_tag :li, class: "fancy-list-item epic", id: "epic-#{epic.id}" do
      concat_span_tag epic.display_caption
      concat_span_tag resize_text(epic.description, 150), class: 'epic-summary'
      safe_concat epics_list_button(epic)
    end
  end

  def epics_list_button(epic)
    content_tag :div, class: 'fancy-list right-content-list' do
      safe_concat epic.edit_link(@project)
      safe_concat epic.delete_link(@project)
    end
  end

  def epic_form(model, path, method)
    overlay_form(model, path, method) do |f|
      safe_concat epic_form_field(f, model)
      safe_concat epic_form_color_field(f)
      safe_concat epic_form_description_field(f)
    end
  end

  def epic_form_field(f, model)
    content_tag :p do
      safe_concat required_form_label(f, :name, t(:field_name))
      safe_concat f.text_field :name, value: model.caption
    end
  end

  def epic_form_description_field(f)
    content_tag :p do
      safe_concat f.label :description, t(:field_description)
      safe_concat f.text_area :description, rows: 5
    end
  end

  def epic_form_color_field(f)
    content_tag :p do
      safe_concat f.label :color, t(:label_color)
      safe_concat color_field_tag f, :color
    end
  end

  def epic_editor_overlay(model = nil, path = nil, method = nil)
    overlay_tag('epic-editor-overlay', 'width:800px') do
      if model
        safe_concat content_tag(:h1, method.eql?(:post) ? t(:link_new_epic) : model.caption)
        safe_concat epic_form(model, path, method)
      end
    end
  end
end

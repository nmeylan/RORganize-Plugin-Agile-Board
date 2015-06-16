module EpicsHelper
  def epics_content
    tab_content('epics') #@see agile_board_tab_helper
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
      concat epic.display_caption
      concat_span_tag resize_text(epic.description, 150), class: 'epic-summary'
      concat agile_board_list_button(epic)
    end
  end

  def epic_form(model, path, method)
    overlay_form(model, path, method) do |f|
      concat f.input :name, my_wrapper_html: {class: "col-sm-10"}, label_html: {class: "col-sm-2"}
      concat agile_board_form_color_field(f)
      concat f.input :description, input_html: {rows: 5}, my_wrapper_html: {class: "col-sm-10"}, label_html: {class: "col-sm-2"}
    end
  end
end

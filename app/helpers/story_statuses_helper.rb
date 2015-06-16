module StoryStatusesHelper
  include AgileBoardHelper

  def statuses_content
    tab_content('statuses') #@see agile_board_tab_helper
  end

  def statuses_list_header
    box_header_tag t(:field_name), 'header header-left' do
      @board_decorator.new_status_link
    end
  end

  def statuses_list
    path = agile_board_plugin::story_status_change_position_path(@project.slug, '-1')
    sortable = 'sortable' if User.current.allowed_to?('change_position', 'Story_statuses', @project)
    content_tag :ul, {class: "fancy-list fancy-list-mini story-statuses-list #{sortable}", 'data-link' => path} do
      @board_decorator.sorted_statuses.collect do |status|
        statuses_list_row(status)
      end.join.html_safe
    end
  end

  def statuses_list_row(status)
    content_tag :li, class: "fancy-list-item status", id: "status-#{status.id}" do
      concat status.display_caption
      concat agile_board_list_button(status)
    end
  end

  def status_form(model, path, method)
    overlay_form(model, path, method) do |f|
      concat f.input :name, my_wrapper_html: {class: "col-sm-10"}, label_html: {class: "col-sm-2"}
      concat f.input :issues_status, collection: model.issues_status_options, include_blank: true,
                      my_wrapper_html: {class: "col-sm-10"},
                      label_html: {class: "col-sm-2"},
                      input_html: {class: "chzn-select cbb-medium search"}
      concat agile_board_form_color_field(f)
    end
  end

end

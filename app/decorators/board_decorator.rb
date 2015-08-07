# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: board_decorator.rb

class BoardDecorator < AgileBoardDecorator
  delegate_all

  def plan_menu_item(selected = false)
    agile_board_menu(h.t(:lable_agile_board_plan), 'plan', :plan, selected)
  end

  def work_menu_item(selected = false)
    agile_board_menu(h.t(:lable_agile_board_work), 'column', :work, selected)
  end

  def report_menu_item(selected = false)
    if User.current.allowed_to?('index', 'Agile_board_reports', context[:project])
      agile_board_menu(h.t(:lable_agile_board_report), 'graph', :report, selected)
    end
  end

  def configuration_menu_item(selected = false)
    if User.current.allowed_to?('configuration', 'Boards', context[:project])
      agile_board_menu(h.t(:lable_agile_board_configuration), 'gear', :configuration, selected)
    end
  end

  def unified_display_mode(selected = false)
    link_to h.t(:link_unified), h.agile_board_plugin::project_agile_board_path(context[:project].slug, :plan, display_mode: :unified), {class: "btn btn-default #{'active' if selected}"}
  end

  def split_display_mode(selected = false)
    link_to h.t(:link_split), h.agile_board_plugin::project_agile_board_path(context[:project].slug, :plan, display_mode: :split), {class: "btn btn-default #{'active' if selected}"}
  end

  # Render a subnav item.
  # @param [String] label : the caption of the subnav item.
  # @param [String] glyph : the name of the glyph to display.
  # @param [Symbol] tab_identifier : the identifier of the tab.
  # @param [Boolean] selected : does the tab is selected?
  def agile_board_menu(label, glyph, tab_identifier, selected)
    agile_board_menu_nav_item(label, glyph, h.agile_board_plugin::project_agile_board_path(context[:project].slug, tab_identifier), selected)
  end

  # Build a hash for subnav item creation.
  # @param [String] label : the caption of the tab.
  # @param [String] glyph : the name of the glyph to display.
  # @param [String] path : the path for the given tab.
  # @param [Boolean] selected : does the tab is selected?
  def agile_board_menu_nav_item(label, glyph, path, selected)
    {caption: h.glyph(label, glyph),
     path: path,
     options: {class: "#{'active' if selected} btn btn-default", remote: false}}
  end

  def delete_link
    h.link_to_with_permissions(h.glyph(h.t(:link_delete), 'trashcan'),
                               h.agile_board_plugin::project_agile_board_path(context[:project].slug),
                               context[:project], nil,
                               {remote: true,
                                'data-confirm' => h.t(:text_delete_agile_board),
                                method: :delete, class: 'button danger', id: 'delete-board-link'}
    )
  end

  def add_points_link
    h.link_to_with_permissions(h.glyph(h.t(:link_add), 'plus'),
                               h.agile_board_plugin::add_points_project_story_points_path(context[:project].slug),
                               context[:project], nil,
                               {remote: true, method: :get, class: 'button'})
  end

  def new_status_link
    agile_board_new_link(h.t(:link_new_status), 'plus', h.agile_board_plugin::new_project_story_status_path(context[:project].slug))
  end

  def new_sprint
    h.link_to_with_permissions(h.glyph(h.t(:link_new_sprint), "sprint"), h.agile_board_plugin::new_project_sprint_path(context[:project].slug), context[:project],
                               nil, {class: 'button', data: {toggle: "dynamic-modal-sprint"}})
  end

  def new_epic_link
    agile_board_new_link(h.t(:link_new_epic), 'plus', h.agile_board_plugin::new_project_epic_path(context[:project].slug))
  end

  def agile_board_new_link(label, glyph_name, path)
    h.link_to_with_permissions(h.glyph(label, glyph_name), path, context[:project],
                               nil, {remote: true, method: :get, class: 'button'})
  end

  def save_points_link(path, method, id)
    h.link_to_with_permissions(h.t(:button_save), path, context[:project], nil,
                               {target: 'self', method: method, class: 'button',
                                id: id, 'data-link' => path})
  end

  def display_points
    context[:points].collect { |point| h.content_tag :span, point.point_edit_link(context[:project]), class: 'point' }.join(' ').html_safe
  end

  def sorted_statuses
    context[:statuses].sort_by(&:position)
  end

  def decorated_epics
    context[:epics]
  end
end
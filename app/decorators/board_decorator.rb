# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: board_decorator.rb

class BoardDecorator < ApplicationDecorator
  delegate_all

  def plan_menu_item
    agile_board_menu(h.t(:lable_agile_board_plan), 'plan', :plan)
  end

  def work_menu_item
    agile_board_menu(h.t(:lable_agile_board_work), 'column', :work)
  end

  def configuration_menu_item
    agile_board_menu(h.t(:lable_agile_board_configuration), 'gear', :configuration)
  end

  def agile_board_menu(label, glyph, param)
    h.agile_board_menu_nav_item(label, glyph, param,
                                h.agile_board_plugin::agile_board_index_path(context[:project].slug, agile_board_menu: param))
  end

  def delete_link
    h.link_to_with_permissions(h.glyph(h.t(:link_delete), 'trashcan'),
                               h.agile_board_plugin::agile_board_path(context[:project].slug, model.id),
                               context[:project], nil,
                               {remote: true,
                                'data-confirm' => h.t(:text_delete_agile_board),
                                method: :delete, class: 'button danger'}
    )
  end

  def new_status_link
    h.link_to_with_permissions(h.glyph(h.t(:link_new_status), 'plus'),
                               h.agile_board_plugin::new_story_status_path(context[:project].slug),
                               context[:project], nil,
                               {remote: true,
                                method: :get, class: 'button'}
    )
  end

  def add_points_link
    h.link_to_with_permissions(h.glyph(h.t(:link_add), 'plus'),
                               h.agile_board_plugin::agile_board_add_points_path(context[:project].slug, model.id),
                               context[:project], nil,
                               {remote: true, method: :get, class: 'button'})
  end

  def new_sprint
    h.link_to_with_permissions(h.glyph(h.t(:link_new_sprint), 'sprint'),
                               h.agile_board_plugin::new_sprint_path(context[:project].slug),
                               context[:project], nil,
                               {remote: true,
                                method: :get, class: 'button'}
    )
  end

  def save_points_link(path, method, id)
    h.link_to_with_permissions(h.t(:button_save),
                               path,
                               context[:project], nil,
                               {target: 'self', method: method, class: 'button',
                                id: id, 'data-link' => path})
  end

  def display_points
    context[:points].collect { |point| h.content_tag :span, point.point_edit_link(context[:project]), class: 'point' }.join(' ').html_safe
  end

  def sorted_statuses
    context[:statuses].sort_by(&:position)
  end
end
# Author: Nicolas Meylan
# Date: 05.12.14
# Encoding: UTF-8
# File: agile_board_reports_helper.rb

module AgileBoardReportsHelper

  # @param [Hash] sprint_hash a hash with this structure . {opened: [sprint, sprint], archived: [sprint, sprint], running: [sprint, sprint]}.
  # @param [Project] project.
  # @param [Symbol] block_identifier : values are : :opened, :running or :archived
  # @param [String] block_title
  def sidebar_block(sprint_hash, project, block_identifier, block_title, selected_sprint)
    if sprint_hash[block_identifier].any?
      safe_concat content_tag :h2, block_title, class: 'agile-board-report-sidebar-title'.freeze
      safe_concat content_tag :ul, sprint_hash[block_identifier].collect { |sprint| sidebar_sprint_render(sprint, project, selected_sprint) }.join.html_safe
    end
  end

  def sidebar_sprint_render(sprint, project, selected_sprint)
    tooltipped_class = sprint.version ? ' tooltipped tooltipped-s'.freeze : ''.freeze
    tooltip_caption = sprint.version ? sprint.version.caption : ''.freeze
    content_tag :li, link_to(resize_text(sprint.caption, 15),
                             agile_board_plugin::agile_board_reports_path(project.slug, sprint.id),
                             class: "#{'selected'.freeze if sprint.id == selected_sprint.id}"),
                class: tooltipped_class, label: tooltip_caption
  end

  def left_sidebar_sprint_render
    content_tag :div, class: 'left-sidebar' do
      content_tag :ul, class: 'filter-sidebar' do
        safe_concat content_tag :li, link_to(glyph(t(:title_sprint_health), 'heart'), '#',class: 'filter-item')
        safe_concat content_tag :li, link_to(glyph(t(:title_burndown_chart),'burndown'), '#',class: 'filter-item')
        safe_concat content_tag :li, link_to(glyph(t(:title_user_stories),'userstory'), '#',class: 'filter-item')
      end
    end
  end
end
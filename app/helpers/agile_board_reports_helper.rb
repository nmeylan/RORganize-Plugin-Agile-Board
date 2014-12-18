# Author: Nicolas Meylan
# Date: 05.12.14
# Encoding: UTF-8
# File: agile_board_reports_helper.rb

module AgileBoardReportsHelper
  include SprintHealthReportHelper
  include SprintsHelper

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
    content_tag :li, link_to(sprint.caption,
                             agile_board_plugin::agile_board_reports_path(project.slug, sprint.id),
                             class: "#{'selected'.freeze if sprint.id == selected_sprint.id}"),
                class: tooltipped_class, label: tooltip_caption
  end

  def left_sidebar_sprint_render
    content_tag :div, class: 'left-sidebar' do
      content_tag :ul, class: 'filter-sidebar' do
        left_sidebar_content
      end
    end
  end

  def left_sidebar_content
    safe_concat content_tag :li, @sprint_decorator.health_link(is_left_sidebar_item_active?(:health))
    safe_concat content_tag :li, @sprint_decorator.burndown_link(is_left_sidebar_item_active?(:burndown))
    safe_concat content_tag :li, @sprint_decorator.show_stories_link(is_left_sidebar_item_active?(:stories))
  end

  def is_left_sidebar_item_active?(item)
    @sessions[:report_menu].eql?(item)
  end

  def report_content
    if @sprint_decorator
      content_tag :div, {id: 'agile-board'} do
        content_tag :div, {id: 'agile-board-content', class: 'report'} do
          safe_concat left_sidebar_sprint_render
          safe_concat report_content_body
          safe_concat clear_both
        end
      end
    else
      no_data(t(:text_no_reports), 'sprint', true)
    end
  end

  def report_content_body
    case @sessions[:report_menu]
      when :health
        sprint_health # @see sprint_health_reports
      when :burndown
        content_tag :div, nil, {id: 'burndown-chart', 'data-link'=> @sprint_decorator.burndown_data_link}
      when :stories
        render_sprint(@sprint_decorator, 'report') # @see sprints_helper
    end
  end
end
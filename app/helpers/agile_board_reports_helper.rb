# Author: Nicolas Meylan
# Date: 05.12.14
# Encoding: UTF-8
# File: agile_board_reports_helper.rb

module AgileBoardReportsHelper
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
    content_tag :li, link_to(resize_text(sprint.caption, 15),
                             agile_board_plugin::agile_board_reports_path(project.slug, sprint.id),
                             class: "#{'selected'.freeze if sprint.id == selected_sprint.id}"),
                class: tooltipped_class, label: tooltip_caption
  end

  def left_sidebar_sprint_render
    content_tag :div, class: 'left-sidebar' do
      content_tag :ul, class: 'filter-sidebar' do
        safe_concat content_tag :li, @sprint_decorator.health_link(@sessions[:report_menu].eql?(:health))
        # safe_concat content_tag :li, link_to(glyph(t(:title_burndown_chart), 'burndown'), '#',
        #                                      class: "filter-item #{'selected' if @sessions[:report_menu].eql?(:burndown)}")
        safe_concat content_tag :li, @sprint_decorator.show_stories_link(@sessions[:report_menu].eql?(:stories))
      end
    end
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
      no_data
    end
  end

  def report_content_body
    case @sessions[:report_menu]
      when :health
        sprint_health
      when :burndown

      when :stories
        render_sprint(@sprint_decorator, 'report')
    end
  end

  def sprint_health
    content_tag :div, class: 'box sprint-health' do
      safe_concat content_tag :div, content_tag(:h2, t(:title_sprint_health)), class: 'header header-left'
      safe_concat sprint_info
      safe_concat sprint_health_by_points_render
      safe_concat sprint_health_by_stories_render
      safe_concat clear_both
    end
  end

  def sprint_info
    content_tag :div, class: 'sprint-info-text' do
      safe_concat content_tag :h2, @sprint_decorator.show_link
      safe_concat @sprint_decorator.display_days_left
      safe_concat @sprint_decorator.display_info_text
    end
  end

  def sprint_health_by_stories_render
    content_tag :div, class: 'splitcontent splitcontentright' do
      safe_concat content_tag :p, t(:text_sprint_health_by_stories), class: 'sprint-health-text'
      safe_concat sprint_health_by_stories_render_content
      safe_concat sprint_health_square(@sprint_health_by_stories.tasks_count, t(:label_tasks))
      safe_concat sprint_health_square("#{@sprint_health_by_stories.tasks_progress} %", t(:title_tasks_progress))
    end
  end

  def sprint_health_by_points_render
    content_tag :div, class: 'splitcontent splitcontentleft' do
      safe_concat content_tag :p, t(:text_sprint_health_by_points), class: 'sprint-health-text'
      safe_concat sprint_health_by_points_render_content
      unit = @sprint_health_by_points.time_elapsed_unit.eql?(:percent) ? '%' : t(:label_plural_day)
      safe_concat sprint_health_square("#{@sprint_health_by_points.time_elapsed} #{unit}", t(:title_time_elapsed))
      safe_concat sprint_health_square("#{@sprint_health_by_points.work_complete} %", t(:title_work_complete))
    end
  end

  def sprint_health_by_points_render_content
    content_tag :div do
      @sprint_health_by_points.distribution.any? ? sprint_health_render_distribution(@sprint_health_by_points.distribution) : no_data
    end
  end

  def sprint_health_by_stories_render_content
    content_tag :div do
      @sprint_health_by_stories.distribution.any? ? sprint_health_render_distribution(@sprint_health_by_stories.distribution) : no_data
    end
  end

  def sprint_health_render_distribution(distribution_hash)
    content_tag :div, class: 'sprint-health-bar' do
      distribution_hash.collect do |status, statistics|
        content_tag :span, statistics[0],
                    {class: "sprint-health-percent tooltipped tooltipped-s",
                     style: "#{style_background_color(status.color)}; width:#{statistics[1]}%; ",
                     label: "#{status.caption} : #{statistics[1]}%"
                    } if statistics[1] > 0
      end.join.html_safe
    end
  end

  def sprint_health_square(info, label)
    content_tag :div, class: 'sprint-health-square' do
      safe_concat content_tag :h1, info
      safe_concat content_tag :span, label
    end
  end

end
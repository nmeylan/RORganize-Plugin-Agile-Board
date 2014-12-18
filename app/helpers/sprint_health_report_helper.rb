module SprintHealthReportHelper

  # Render the report of a sprint health.
  # Start by display sprint info.
  # Then display progression (by points / stories).
  # Then display the statistics bar.
  def sprint_health
    content_tag :div, class: 'box sprint-health' do
      safe_concat content_tag :div, content_tag(:h2, t(:title_sprint_health)), class: 'header header-left'
      safe_concat sprint_info
      safe_concat sprint_health_fragment_render('left', 'points')
      safe_concat sprint_health_fragment_render('right', 'stories')
      safe_concat clear_both
      safe_concat sprint_health_statistics_render
      safe_concat info_tag(nil, {id: 'statistics-info'})
    end
  end

  # render a square item that display some sprint health info.
  # @param [String] info : data to display.
  # @param [String] label : legend.
  def sprint_health_square(info, label)
    content_tag :div, class: 'sprint-health-square' do
      safe_concat content_tag :h1, info
      safe_concat content_tag :span, label
    end
  end

  # Build a progress bar for the sprint progress depending on distribution (points or number of stories).
  # @param [Hash] distribution_hash : with this structure : {Status => [distribution, percent], Status => [distribution, percent]}
  # Key is a StoryStatus (a frozen complex object). Value is an array of size 2 [Numeric, Numeric].
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

  # Render the sprint health statistic bar. That display 5 square items.
  def sprint_health_statistics_render
    content_tag :div, class: 'statistics-bar' do
      unit = @sprint_health.time_elapsed_unit.eql?(:percent) ? '%' : t(:label_plural_day)
      safe_concat sprint_health_square("#{@sprint_health.time_elapsed} #{unit}", t(:title_time_elapsed))
      safe_concat sprint_health_square("#{@sprint_health.work_complete} %", t(:title_work_complete))
      safe_concat sprint_health_square("#{@sprint_health.scope_change} %", t(:title_scope_change))
      safe_concat sprint_health_square(@sprint_health.tasks_count, t(:label_tasks))
      safe_concat sprint_health_square("#{@sprint_health.tasks_progress} %", t(:title_tasks_progress))
    end
  end

  def sprint_health_by_stories_render_content
    content_tag :div do
      @sprint_health.stories_distribution.any? ? sprint_health_render_distribution(@sprint_health.stories_distribution) : no_data
    end
  end

  def sprint_health_by_points_render_content
    content_tag :div do
      @sprint_health.points_distribution.any? ? sprint_health_render_distribution(@sprint_health.points_distribution) : no_data
    end
  end

  # Render sprint health progress bar depending on group_by (stories or points).
  # @param [String] float_position : right or left.
  # @param [String] group_by : stories or points.
  def sprint_health_fragment_render(float_position, group_by)
    content_tag :div, class: "splitcontent splitcontent#{float_position}" do
      safe_concat content_tag :p, t("text_sprint_health_by_#{group_by}".to_sym), class: 'sprint-health-text'
      safe_concat send("sprint_health_by_#{group_by}_render_content")
    end
  end

  # Render a sprint info text. Including sprint name, days left, start and end date, version.
  def sprint_info
    content_tag :div, class: 'sprint-info-text' do
      safe_concat content_tag :h2, @sprint_decorator.show_link
      safe_concat @sprint_decorator.display_days_left
      safe_concat @sprint_decorator.display_info_text
    end
  end
end

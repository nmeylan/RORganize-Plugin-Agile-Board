# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: sprint_decorator.rb

class SprintDecorator < AgileBoardDecorator
  include SprintDecoratorLink
  decorates_association :stories
  delegate_all


  def display_count_stories
    h.content_tag :span, "#{model.stories.size} #{h.t(:text_stories)}", {class: 'counter total-entries stories-counter'}
  end

  def display_count_points
    h.content_tag :span, "#{model.count_points} #{h.t(:text_points)}", {class: 'counter total-entries points-counter'}
  end

  def display_version
    display_info_square(model.version, 'milestone') unless model.version.nil?
  end

  # @return [String] start date.
  def display_start_date
    model.start_date ? model.start_date : '-'
  end

  # @return [String] target_date.
  def display_target_date
    model.end_date ? model.end_date : h.t(:text_no_end_date)
  end

  def display_dates
    unless model.id.eql?(-1)
      h.content_tag :span, class: 'sprint-dates-header info-square' do
        h.concat_span_tag h.glyph(' ', 'calendar')
        h.concat_span_tag self.display_start_date
        h.concat_span_tag '-', {class: 'sprint-dates-separator'}
        h.concat_span_tag self.display_target_date
      end
    end
  end

  def display_info_text
    h.content_tag :div, {class: 'sprint-date-range'} do
      h.concat "#{h.t(:text_running).capitalize} #{h.t(:text_from)} "
      h.concat content_tag :span, self.display_start_date
      h.concat " #{h.t(:text_to)} "
      h.concat content_tag :span, self.display_target_date
      display_target_phase_text
    end
  end

  def display_target_phase_text
    if self.version
      h.concat ", #{h.t(:text_with)} #{h.t(:field_version)} "
      h.concat self.display_version
    end
    h.concat '.'
  end

  def sorted_stories
    self.stories.sort_by(&:position)
  end

  def display_days_left
    unless model.end_date.nil?
      days_left = (model.end_date - Date.today).to_i
      h.content_tag :span, "#{days_left < 0 ? 0 : days_left} #{days_left == 1 ? h.t(:text_day_left) : h.t(:text_days_left)}", class: 'sprint-days-left'
    end
  end
end
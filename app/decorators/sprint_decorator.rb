# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: sprint_decorator.rb

class SprintDecorator < AgileBoardDecorator
  decorates_association :stories
  delegate_all

  def new_story(render_button = true)
    h.link_to_with_permissions(h.glyph(h.t(:link_new_story), 'tasks'),
                               h.agile_board_plugin::new_user_story_path(context[:project].slug),
                               context[:project], nil,
                               {remote: true, class: "#{'button' if render_button}"}
    )
  end

  def edit_link
    h.link_to_with_permissions(h.glyph(h.t(:link_edit), 'pencil'),
                               h.agile_board_plugin::edit_sprint_path(context[:project].slug, model.id),
                               context[:project], nil,
                               {remote: true, class: ''}
    )
  end

  def delete_link
    h.link_to_with_permissions(h.glyph(h.t(:link_delete), 'trashcan'),
                               h.agile_board_plugin::sprint_path(context[:project].slug, model.id),
                               context[:project], nil,
                               {remote: true, class: 'danger-dropdown', confirm: h.t(:text_delete_sprint), method: :delete}
    )
  end

  def display_count_stories
    h.content_tag :span, "#{model.stories.size} stories", {class: 'counter total-entries'}
  end

  def display_count_points
    h.content_tag :span, "#{model.count_points} points", {class: 'counter total-entries'}
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
end
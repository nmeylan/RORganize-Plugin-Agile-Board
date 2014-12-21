# Author: Nicolas Meylan
# Date: 07.12.14
# Encoding: UTF-8
# File: sprint_decorator_link.rb

module SprintDecoratorLink

  def new_story(render_button = true)
    h.link_to_with_permissions(h.glyph(h.t(:link_new_story), 'tasks'),
                               h.agile_board_plugin::new_user_story_path(context[:project].slug, sprint_id: model.id),
                               context[:project], nil,
                               {remote: true, class: "#{button_class(render_button)}", method: :get}
    ) unless model.archived?
  end

  def edit_link
    super(context[:project], h.agile_board_plugin::edit_sprint_path(context[:project].slug, model.id), false) unless model.archived?
  end

  def delete_link
    super(context[:project], h.agile_board_plugin::sprint_path(context[:project].slug, model.id), false)
  end

  def archive_link
    h.link_to_with_permissions(h.glyph(h.t(:link_archive), 'lock'),
                               h.agile_board_plugin::sprint_archive_path(context[:project].slug, model.id),
                               context[:project], nil,
                               {remote: true, 'data-confirm' => h.t(:confirm_archive_sprint), method: :put}
    ) unless model.archived?
  end

  def restore_link
    h.link_to_with_permissions(h.glyph(h.t(:link_restore), 'unlock'),
                               h.agile_board_plugin::sprint_restore_path(context[:project].slug, model.id),
                               context[:project], nil,
                               {remote: true, 'data-confirm' => h.t(:confirm_restore_sprint), method: :put}
    ) if model.archived?
  end

  def show_link
    h.link_to self.resized_caption(25), h.agile_board_plugin::agile_board_path(context[:project].slug, :work, sprint_id: model.id),
              {class: 'sprint-show tooltipped tooltipped-s', label: h.t(:tooltip_view_map)}
  end

  def health_link(selected)
    h.link_to(h.glyph(h.t(:title_sprint_health), 'pulse'),
              h.agile_board_plugin::health_agile_board_reports_path(context[:project].slug, model.id),
              class: "filter-item #{'selected' if selected}")
  end

  def show_stories_link(selected)
    h.link_to(h.glyph(h.t(:title_user_stories), 'userstory'),
              h.agile_board_plugin::show_stories_agile_board_reports_path(context[:project].slug, model.id),
              class: "filter-item #{'selected' if selected}")
  end

  def burndown_link(selected)
    h.link_to(h.glyph(h.t(:title_burndown_chart), 'burndown'),
              h.agile_board_plugin::burndown_agile_board_reports_path(context[:project].slug, model.id),
              class: "filter-item #{'selected' if selected}")
  end

  def burndown_data_link
    h.agile_board_plugin::burndown_data_agile_board_reports_path(context[:project].slug, model.id)
  end
end
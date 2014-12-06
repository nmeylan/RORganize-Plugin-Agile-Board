# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: board_decorator.rb

class StoryStatusDecorator < AgileBoardDecorator
  delegate_all


  def edit_link(project, path = nil)
    super(project, h.agile_board_plugin::edit_story_status_path(project.slug, model.id))
  end

  def delete_link(project, path = nil)
    super(project, h.agile_board_plugin::story_status_path(project.slug, model.id))
  end

  def display_caption
    h.content_tag :span, self.resized_caption(25), {class: 'issue-status', style: "#{h.style_background_color(model.color)}"}
  end

  def issues_status_options
    context[:issues_statuses].collect{|status| [status.caption, status.id]}
  end
end
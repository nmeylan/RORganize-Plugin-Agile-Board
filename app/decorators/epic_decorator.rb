# Author: Nicolas Meylan
# Date: 01.11.14
# Encoding: UTF-8
# File: epic_decorator.rb

class EpicDecorator < AgileBoardDecorator
  delegate_all

  def edit_link(project, path = nil)
    super(project, h.agile_board_plugin::edit_project_epic_path(project.slug, model.id))
  end

  def delete_link(project, path = nil)
    super(project, h.agile_board_plugin::project_epic_path(project.slug, model.id))
  end

  def display_caption
    h.content_tag :span, h.glyph(self.resized_caption(25), 'sword'.freeze), {class: 'info-square epic-caption', style: "#{h.style_background_color(model.color)}"}
  end
end
# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: board_decorator.rb

class StoryStatusDecorator < ApplicationDecorator
  delegate_all


  def edit_link(project)
    h.link_to_with_permissions(h.glyph(h.t(:link_edit), 'pencil'),
                               h.agile_board_plugin::edit_story_status_path(project.slug, model.id),
                               project, nil, {remote: true, method: :get, class: 'button'})
  end

  def delete_link(project)
    h.link_to_with_permissions(h.glyph(h.t(:link_delete), 'trashcan'),
                               h.agile_board_plugin::story_status_path(project.slug, model.id),
                               project, nil, {remote: true, method: :delete, class: 'button danger', confirm: h.t(:text_delete_item)})
  end

  def display_caption
    h.content_tag :span, {class: 'issue-status', style: "background-color: #{model.color}"} do
      model.caption
    end
  end

  def <=>(other)
    self.position <=> other.position
  end
end
# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: sprint_decorator.rb

class SprintDecorator < ApplicationDecorator
  decorates_association :stories
  delegate_all

  def new_story
    h.link_to_with_permissions(h.glyph(h.t(:link_new_story), 'tasks'),
                               h.agile_board_plugin::new_user_story_path(context[:project].slug),
                               context[:project], nil,
                               {remote: true, class: 'button'}
    )
  end

  def edit_link
    h.link_to_with_permissions(h.glyph(h.t(:link_edit), 'pencil'),
                               h.agile_board_plugin::edit_sprint_path(context[:project].slug, model.id),
                               context[:project], nil,
                               {remote: true, class: 'button'}
    )
  end

  def delete_link
    h.link_to_with_permissions(h.glyph(h.t(:link_delete), 'trashcan'),
                               h.agile_board_plugin::sprint_path(context[:project].slug, model.id),
                               context[:project], nil,
                               {remote: true, class: 'button danger', confirm: h.t(:text_delete_sprint)}
    )
  end
end
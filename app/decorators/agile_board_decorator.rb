# Author: Nicolas Meylan
# Date: 01.11.14
# Encoding: UTF-8
# File: agile_board_decorator.rb

class AgileBoardDecorator < ApplicationDecorator
  def edit_link(project, path)
    h.link_to_with_permissions(h.glyph(h.t(:link_edit), 'pencil'),
                               path,
                               project, nil, {remote: true, method: :get, class: 'button'})
  end

  def delete_link(project, path)
    h.link_to_with_permissions(h.glyph(h.t(:link_delete), 'trashcan'),
                               path,
                               project, nil, {remote: true, method: :delete, class: 'button danger', confirm: h.t(:text_delete_item)})
  end
end
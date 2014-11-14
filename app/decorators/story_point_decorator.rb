# Author: Nicolas Meylan
# Date: 31.10.14
# Encoding: UTF-8
# File: board_decorator.rb

class StoryPointDecorator < AgileBoardDecorator
  delegate_all

  def point_edit_link(project)
    link = h.link_to_with_permissions(model.value,
                             h.agile_board_plugin::edit_story_point_path(project.slug, model.id),
                             project, nil,
                             {remote: true, method: :get, id: "edit-point-#{model.id}"})
    link ? link : model.value
  end

end
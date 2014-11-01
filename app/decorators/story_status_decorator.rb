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
    h.content_tag :span, {class: 'issue-status', style: "background-color: #{model.color}"} do
      model.caption
    end
  end

  def <=>(other)
    self.position <=> other.position
  end
end
module StoryPointsHelper

  def points_content(addition = false)
    content_tag :div, id: 'points-tab', style: "display:none" do
      safe_concat @board_decorator.display_points
      if addition
        points_addition
      else
        safe_concat @board_decorator.add_points_link
      end
    end
  end

  def points_addition
    path = agile_board_plugin::add_points_story_points_path(@project.slug)
    safe_concat text_field_tag(:points, nil, {placeholder: '10, 35, 50'})
    safe_concat @board_decorator.save_points_link(path, :post, 'submit-points-addition')
  end



  def point_editor(point)
    path = agile_board_plugin::story_point_path(@project.slug, point.id)
    content_tag :span do
      safe_concat text_field_tag(:point, point.value)
      safe_concat @board_decorator.save_points_link(path, :put, 'submit-points-edition')
    end
  end
end

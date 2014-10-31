module BoardsHelper
  include StoryPointsHelper
  include StoryStatusesHelper

  def agile_board_menu
    subnav_tag('agile-board-menu', 'agile-board-menu',
               @board_decorator.plan_menu_item, @board_decorator.work_menu_item,
               @board_decorator.configuration_menu_item)
  end

  def agile_board
    content_tag :div, {id: 'agile-board'} do
      if @board_decorator.nil?
        safe_concat t(:text_no_agile_board)
        safe_concat create_link
      else
        safe_concat agile_board_menu
        safe_concat agile_board_content
      end
    end
  end

  def agile_board_menu_nav_item(label, glyph, type, path)
    {caption: glyph(label, glyph),
     path: path,
     options: {class: "#{'selected' if nav_item_selected?(type.to_sym)} subnav-item"}}
  end

  def nav_item_selected?(type)
    @sessions[:agile_board_menu].eql?(type)
  end

  def agile_board_content
    content_tag :div, {id: 'agile-board-content'} do
      render_content
    end
  end

  def render_content
    case @sessions[:agile_board_menu]
      when :plan
        plan_content
      when :work
        work_content
      when :configuration
        configuration_content
    end
  end


  def configuration_content
    safe_concat horizontal_tabs('configuration-tab',
                                [{name: 'points-tab', element: glyph(t(:link_story_points), 'coin')},
                                 {name: 'statuses-tab', element: glyph(t(:link_story_statuses), 'dashboard')}])

    safe_concat points_content
    safe_concat statuses_content
  end

  def create_link
    link_to_with_permissions(t(:label_create),
                               agile_board_plugin::agile_board_index_path(@project.slug),
                               @project, nil, {remote: true, class: 'button', method: :post})
  end

  def work_content
    content_tag :p, 'aaa'
  end

  def plan_content
    content_tag :p, 'bb'
  end

end

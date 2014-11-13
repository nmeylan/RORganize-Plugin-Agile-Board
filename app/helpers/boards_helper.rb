module BoardsHelper
  include AgileBoardHelper
  include StoryPointsHelper
  include StoryStatusesHelper
  include EpicsHelper
  include SprintsHelper
  include StoryMapHelper

  def agile_board_menu
    #TODO add permission control
    content_tag :div do
      safe_concat display_mode_menu
      safe_concat subnav_tag('agile-board-menu', 'agile-board-menu',
                             @board_decorator.plan_menu_item, @board_decorator.work_menu_item,
                             @board_decorator.configuration_menu_item)
    end
  end

  def display_mode_menu
    if @sessions[:agile_board_menu].eql?(:plan)
      group_button_tag(@board_decorator.unified_display_mode(unified_content?),
                       @board_decorator.split_display_mode(split_content?))
    end
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
    # TODO display or not tab (depending on permissions)
    safe_concat horizontal_tabs('configuration-tab',
                                [{name: 'epics-tab', element: medium_glyph(t(:link_epics), 'sword')},
                                 {name: 'statuses-tab', element: glyph(t(:link_story_statuses), 'dashboard')},
                                 {name: 'points-tab', element: glyph(t(:link_story_points), 'coin')}])

    safe_concat points_content
    safe_concat statuses_content
    safe_concat epics_content
  end

  def create_link
    link_to_with_permissions(t(:label_create),
                             agile_board_plugin::agile_board_index_path(@project.slug),
                             @project, nil, {remote: true, class: 'button', method: :post})
  end

  def work_content
    safe_concat clear_both
    safe_concat story_map_render(@statuses, @stories_hash)
  end

  def plan_content
    safe_concat clear_both
    safe_concat content_tag :div, class: 'agile-board-plan', &Proc.new {
      sprints_content(@sprints_decorator)
      safe_concat render_sprint(@backlog, "backlog #{'splitcontentright' if split_content?}")
    }
  end


end

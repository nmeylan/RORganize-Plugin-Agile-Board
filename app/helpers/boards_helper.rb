module BoardsHelper
  include AgileBoardHelper
  include StoryPointsHelper
  include StoryStatusesHelper
  include EpicsHelper
  include SprintsHelper
  include StoryMapHelper

  # Render a subnav tag to choose the menu.
  def agile_board_menu
    content_tag :div do
      safe_concat subnav_tag('agile-board-menu', 'agile-board-menu',
                             @board_decorator.plan_menu_item(nav_item_selected?(:plan)),
                             @board_decorator.work_menu_item(nav_item_selected?(:work)),
                             @board_decorator.report_menu_item(nav_item_selected?(:report)),
                             @board_decorator.configuration_menu_item(nav_item_selected?(:configuration)))
    end
  end

  def nav_item_selected?(type)
    @sessions[:agile_board_menu].eql?(type)
  end

  # Render a button group tag to choose the display mode.
  def display_mode_menu
    if @sessions[:agile_board_menu].eql?(:plan)
      safe_concat group_button_tag(@board_decorator.unified_display_mode(unified_content?),
                                   @board_decorator.split_display_mode(split_content?))
      safe_concat agile_board_search_input
      concat_span_tag glyph('', 'info'), {label: t(:info_filter_syntax),
                                          class: 'tooltipped tooltipped-multiline tooltipped-multiline-pre tooltipped-s'}
    end
  end

  def agile_board_search_input
    content_tag :div, class: 'subnav-search user-stories-search' do
      safe_concat text_field_tag :user_story_search, nil, {id: 'user-stories-search',
                                                           placeholder: t(:placeholder_search_stories),
                                                           class: 'search-input'}
      safe_concat content_tag :span, nil, class: 'octicon octicon-search search-input-icon'
      safe_concat content_tag :span, nil, class: 'octicon octicon-x clear-input-icon'
    end
  end

  def tooltip_text
    "SYNTAX: space between filter are interpreted as AND operator. "+
        "\nSearch is case insensitive."+
        "\n\nValues can contain spaces until the next key."+
        "\n---------------------------------------------------------------------------------------\n"+
        "title:my title\t\t\t\t\t\t     category:my category"+
        "\ntracker:bug\t\t\t\t\t\t\t\t    epic:an epic"+
        "\nstatus:to do"+
        "\n---------------------------------------------------------------------------------------\n"+
        "\nValid keys are : category, epic, status, title, tracker."+
        "\n\nThe title: key is not mandatory but, if it not specified, value should be placed as the first parameter."
  end

  def agile_board
    content_tag :div, {id: 'agile-board'} do
      if @board_decorator.nil?
        safe_concat t(:text_no_agile_board)
        safe_concat create_link
      else
        display_mode_menu
        safe_concat agile_board_content
      end
    end
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


  # Render the nav tab for configuration content.
  def configuration_content
    tabs = []
    tabs << {name: 'epics-tab', element: medium_glyph(t(:link_epics), 'sword')} if User.current.allowed_to?('index', 'Epics', @project)
    tabs << {name: 'statuses-tab', element: glyph(t(:link_story_statuses), 'dashboard')} if User.current.allowed_to?('index', 'Story_statuses', @project)
    tabs << {name: 'points-tab', element: glyph(t(:link_story_points), 'coin')} if User.current.allowed_to?('index', 'Story_points', @project)
    safe_concat @board_decorator.delete_link
    safe_concat horizontal_tabs('configuration-tab', tabs) unless tabs.empty?
    safe_concat points_content
    safe_concat statuses_content
    safe_concat epics_content
  end

  def create_link
    link_to_with_permissions(t(:label_create),
                             agile_board_plugin::agile_board_path(@project.slug),
                             @project, nil, {remote: true, class: 'button', method: :post})
  end

  def work_content
    safe_concat clear_both
    safe_concat story_map_render(@statuses, @sprints, @stories_hash)
  end

  def plan_content
    safe_concat clear_both
    safe_concat content_tag :div, class: 'agile-board-plan', &Proc.new {
                                  sprints_content(@sprints_decorator)
                                  safe_concat render_sprint(@backlog, "backlog #{'splitcontentright' if split_content?}")
                                }
    safe_concat clear_both
  end


end

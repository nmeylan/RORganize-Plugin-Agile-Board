# Author: Nicolas Meylan
# Date: 05.12.14
# Encoding: UTF-8
# File: agile_board_reports.rb

require 'agile_board/view_objects/sprint_health'
require 'agile_board/view_objects/sprint_burndown'
class AgileBoardReportsController < AgileBoardController
  include GenericCallbacks
  before_action { |c| c.add_action_alias = {'health' => 'index', 'show_stories' => 'index', 'burndown' => 'index'} }
  before_action :check_permission, except: [:burndown_data]
  before_action :load_sprints_hash, except: [:burndown_data]
  before_action :load_sprint
  before_action { |c| c.menu_context :project_menu }
  before_action { |c| c.menu_item('boards') }
  before_action { |c| c.top_menu_item('projects') }
  helper BoardsHelper

  def index
    @sessions[:agile_board_menu] = :report
    @sessions[:report_menu] ||= :health
    gon.action = @sessions[:report_menu]
    if @sprint_decorator
      @sprint_health = SprintHealth.new(@sprint_decorator)
    end
    generic_index_callback({sprint_hash: @sprint_hash})
  end

  def health
    @sessions[:report_menu] = :health
    @sprint_health = SprintHealth.new(@sprint_decorator)
    generic_index_callback({sprint_hash: @sprint_hash})
  end

  def show_stories
    @sessions[:report_menu] = :stories
    generic_index_callback({sprint_hash: @sprint_hash})
  end

  def burndown
    @sessions[:report_menu] = :burndown
    generic_index_callback({sprint_hash: @sprint_hash})
  end

  def burndown_data
    json = SprintBurndown.new(@sprint_decorator).json
    respond_to do |format|
      format.html { render json: json }
      format.json { render json: json }
    end
  end

  private
  def load_sprints_hash
    @sprint_hash = @board_decorator.hash_group_by_is_archived
  end

  def load_sprint
    if params[:sprint_id]
      id = params[:sprint_id]
    else
      first_sprint = @sprint_hash.values.flatten.first
      id = first_sprint && first_sprint.id
    end
    @sprint_decorator = Sprint.includes(stories: [:status, :points, :issues, :tracker, :epic, :category]).find_by_id_and_board_id(id, @board_decorator.id)
    if @sprint_decorator
      @sprint_decorator = @sprint_decorator.decorate(context: {project: @project})
    elsif params[:sprint_id]
      render_404
    end
  end

end
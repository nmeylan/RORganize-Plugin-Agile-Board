# Author: Nicolas Meylan
# Date: 05.12.14
# Encoding: UTF-8
# File: agile_board_reports.rb

require 'agile_board/view_objects/sprint_health_by_points'
require 'agile_board/view_objects/sprint_health_by_stories'
class AgileBoardReportsController < AgileBoardController
  before_filter :check_permission
  before_action :load_sprints_hash, only: [:index]
  before_action :load_sprint
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item('boards') }
  before_filter { |c| c.top_menu_item('projects') }
  helper BoardsHelper

  def index
    @sessions[:agile_board_menu] = :report
    @sessions[:report_menu] ||= :health

    if @sprint_decorator
      @sprint_health_by_points = SprintHealthByPoints.new(@sprint_decorator)
      @sprint_health_by_stories = SprintHealthByStories.new(@sprint_decorator)
    end
    respond_to do |format|
      format.html { render :index, locals: {sprint_hash: @sprint_hash} }
      format.js { respond_to_js action: 'index' }
    end
  end

  def health
    @sessions[:report_menu] = :health
    @sprint_health_by_points = SprintHealthByPoints.new(@sprint_decorator)
    @sprint_health_by_stories = SprintHealthByStories.new(@sprint_decorator)
    respond_to do |format|
      format.html { render :index }
      format.js { respond_to_js action: 'index' }
    end
  end

  def show_stories
    @sessions[:report_menu] = :stories
    respond_to do |format|
      format.html { render :index }
      format.js { respond_to_js action: 'index' }
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
# Author: Nicolas Meylan
# Date: 05.12.14
# Encoding: UTF-8
# File: agile_board_reports.rb

require 'agile_board/view_objects/sprint_health_by_points'
require 'agile_board/view_objects/sprint_health_by_stories'
class AgileBoardReportsController < AgileBoardController
  before_filter :check_permission
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item('boards') }
  before_filter { |c| c.top_menu_item('projects') }
  helper BoardsHelper

  def index
    @sessions[:agile_board_menu] = :report
    @sessions[:report_menu] ||= :health
    sprint_hash = @board_decorator.hash_group_by_is_archived
    @sprint_decorator = load_sprint(sprint_hash).decorate(context: {project: @project})
    @sprint_health_by_points = SprintHealthByPoints.new(@sprint_decorator)
    @sprint_health_by_stories = SprintHealthByStories.new(@sprint_decorator)
    respond_to do |format|
      format.html { render :index, locals: {sprint_hash: sprint_hash} }
      format.js { respond_to_js action: 'index' }
    end
  end

  def load_sprint(sprint_hash)
    id = params[:sprint_id] || sprint_hash.values.flatten.first.id
    Sprint.includes(stories: [:status, :points]).find_by_id(id)
  end

end
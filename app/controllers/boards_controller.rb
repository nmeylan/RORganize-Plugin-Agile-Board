class BoardsController < ApplicationController
  before_action :set_board, only: [:index, :add_points, :destroy]
  before_action :check_permission
  include Rorganize::RichController::ProjectContext
  # GET /boards
  def index
    @sessions[:agile_board_menu] ||= :work
    @sessions[:agile_board_menu] = params[:agile_board_menu].to_sym if params[:agile_board_menu]

    select_menu
    respond_to do |format|
      format.html { render :index }
      format.js { respond_to_js action: 'index' }
    end
  end

  def create
    @board_decorator = Board.create(project_id: @project.id).decorate(context: {project: @project})
    respond_to do |format|
      format.js { js_redirect_to agile_board_plugin::agile_board_index_path(@project.slug) }
    end
  end

  def plan
    @backlog = Sprint.new(name: 'Backlog')
    @backlog.stories = UserStory.where(sprint_id: nil)
    @backlog.stories << UserStory.new(title: 'My Story', tracker_id: 1, status_id: StoryStatus.find_by_board_id_and_position(@board_decorator.id, 0).id)
    @backlog = @backlog.decorate(context: {project: @project})
    @sprints_decorator = Sprint.where(board_id: @board_decorator.id).includes(:stories).decorate(context: {project: @project})
    @sprints_decorator << Sprint.new(name: 'Sprint 1', id: 1).decorate(context: {project: @project})
    @sprints_decorator << Sprint.new(name: 'Sprint 2', id: 2).decorate(context: {project: @project})
  end

  def work

  end

  def configuration
    @board_decorator.context.merge!({points: StoryPoint.where(board_id: @board_decorator.id).decorate, statuses: StoryStatus.where(board_id: @board_decorator.id).decorate})
  end

  def add_points
    if request.get?
      addition = true
    else
      @board_decorator.add_points(params[:points])
      addition = false
    end
    @board_decorator.context.merge!({points: StoryPoint.where(board_id: @board_decorator.id).decorate})
    respond_to do |format|
      format.js { respond_to_js action: 'add_points', locals: {addition: addition}, response_header: addition ? '' : :success, response_content: t(:successful_creation) }
    end
  end

  def destroy
    @board_decorator.destroy
    respond_to do |format|
      flash[:notice] = 'Board was successfully destroyed.'
      format.js { js_redirect_to (agile_board_plugin::agile_board_index_path(@project.slug)) }
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_board
    @board_decorator = Board.find_by_project_id(@project.id)
    @board_decorator = @board_decorator.decorate(context: {project: @project}) if @board_decorator
  end

  def select_menu
    if @board_decorator
      case @sessions[:agile_board_menu]
        when :work
          work
        when :plan
          plan
        when :configuration
          configuration
      end
    else
      @locals = {}
    end
  end

  # Only allow a trusted parameter "white list" through.
  def board_params
    params.require(:board).permit(:velocity)
  end
end

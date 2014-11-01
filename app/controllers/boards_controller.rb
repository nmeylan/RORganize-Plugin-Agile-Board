class BoardsController < AgileBoardController
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
    @backlog = Sprint.new(id: -1, name: 'Backlog')
    @backlog.stories = UserStory.where(sprint_id: nil)
    @backlog.stories << UserStory.new(points: StoryPoint.new(value: 10), title: 'My Story', tracker_id: 1, status_id: StoryStatus.find_by_board_id_and_position(@board_decorator.id, 0).id)
    @backlog = @backlog.decorate(context: {project: @project})
    @sprints_decorator = Sprint.ordered_sprints(@board.id).decorate(context: {project: @project})
  end

  def work

  end

  def configuration
    @board_decorator.context.merge!({points: StoryPoint.where(board_id: @board_decorator.id).decorate,
                                     statuses: StoryStatus.where(board_id: @board_decorator.id).decorate,
                                     epics: Epic.where(board_id: @board_decorator.id).decorate})
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

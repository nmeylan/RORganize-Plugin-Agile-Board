class SprintsController < AgileBoardController
  include Rorganize::RichController::GenericCallbacks
  before_action :set_sprint, only: [:show, :edit, :update, :destroy]


  # GET /sprints
  def index
    @sprints = Sprint.all
  end

  # GET /sprints/1
  def show
  end

  # GET /sprints/new
  def new
    @sprint = Sprint.new
    agile_board_form_callback(agile_board_plugin::sprints_path(@project.slug), :post)
  end

  # GET /sprints/1/edit
  def edit
    agile_board_form_callback(agile_board_plugin::sprint_path(@project.slug, @sprint.id), :put)
  end

  # POST /sprints
  def create
    @sprint = Sprint.new(sprint_params)
    @sprint.board = @board
    result = @sprint.save
    set_sprints
    simple_js_callback(result, :create, @sprint, {new: false})
  end

  # PATCH/PUT /sprints/1
  def update
    result = @sprint.update(sprint_params)
    set_sprints
    simple_js_callback(result, :update, @sprint)
  end

  # DELETE /sprints/1
  def destroy
    simple_js_callback(@sprint.destroy, :delete, @sprint, {id: params[:id]})
  end


  def generate_sprint_name
    count = Sprint.where(version_id: params[:value]).pluck('count(id)')
    @name = "Sprint #{count.first}"
    respond_to do |format|
      format.js { respond_to_js }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_sprint
    @sprint = Sprint.find(params[:id])
  end

  def set_sprints
    @sprints_decorator = Sprint.ordered_sprints(@board.id).decorate(context: {project: @project})
  end


  # Only allow a trusted parameter "white list" through.
  def sprint_params
    params.require(:sprint).permit(:name, :start_date, :end_date, :version_id)
  end
end

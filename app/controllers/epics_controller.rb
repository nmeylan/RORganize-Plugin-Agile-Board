class EpicsController < AgileBoardController
  include Rorganize::RichController::GenericCallbacks
  before_action :set_epic, only: [:show, :edit, :update, :destroy]

  # GET /epics
  def index
    @epics = Epic.all
  end

  # GET /epics/1
  def show
  end

  # GET /epics/new
  def new
    @epic = Epic.new(color: '#6cc644')
    agile_board_form_callback(agile_board_plugin::epics_path(@project.slug), :post)
  end

  # GET /epics/1/edit
  def edit
    agile_board_form_callback(agile_board_plugin::epic_path(@project.slug, @epic.id), :put)
  end

  # POST /epics
  def create
    @epic = Epic.new(epic_params).decorate
    @epic.board = @board
    simple_js_callback(@epic.save, :create, @epic)
  end

  # PATCH/PUT /epics/1
  def update
    simple_js_callback(@epic.update(epic_params), :update, @epic)
  end

  # DELETE /epics/1
  def destroy
    simple_js_callback(@epic.destroy, :delete, @epic, {id: params[:id]})
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_epic
      @epic = Epic.find(params[:id])
      @epic = @epic.decorate if @epic
    end

    # Only allow a trusted parameter "white list" through.
    def epic_params
      params.require(:epic).permit(:name, :description, :color)
    end
end

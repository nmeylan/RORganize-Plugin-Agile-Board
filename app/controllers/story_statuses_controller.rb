class StoryStatusesController < AgileBoardController
  include Rorganize::RichController::GenericCallbacks
  before_action :set_story_status, only: [:show, :edit, :update, :destroy]
  before_action :check_permission
  # GET /story_statuses
  def index
    @story_statuses = StoryStatus.all
  end

  # GET /story_statuses/new
  def new
    @story_status = StoryStatus.new(color: '#6cc644').decorate(context: {issues_statuses: IssuesStatus.all.includes(:enumeration)})
    agile_board_form_callback(agile_board_plugin::story_statuses_path(@project.slug), :post)
  end

  # GET /story_statuses/1/edit
  def edit
    @story_status.context = {issues_statuses: IssuesStatus.all.includes(:enumeration)}
    agile_board_form_callback(agile_board_plugin::story_status_path(@project.slug, @story_status.id), :put)
  end

  # POST /story_statuses
  def create
    @story_status = StoryStatus.new(story_status_params).decorate
    @story_status.board = @board
    simple_js_callback(@story_status.save, :create, @story_status)
  end

  # PATCH/PUT /story_statuses/1
  def update
    simple_js_callback(@story_status.update(story_status_params), :update, @story_status)
  end

  def change_position
    StoryStatus.update_positions(@project.id, params[:ids])
    respond_to do |format|
      format.js { respond_to_js action: 'do_nothing', response_header: :success, response_content: t(:successful_update) }
    end
  end

  # DELETE /story_statuses/1
  def destroy
    simple_js_callback(@story_status.destroy, :delete, @story_status, {id: params[:id]})
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_story_status
    @story_status = StoryStatus.find(params[:id])
    @story_status = @story_status.decorate if @story_status
  end

  # Only allow a trusted parameter "white list" through.
  def story_status_params
    params.require(:story_status).permit(:name, :color, :issues_status_id)
  end
end

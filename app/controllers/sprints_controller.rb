class SprintsController < AgileBoardController
  include Rorganize::RichController::GenericCallbacks
  before_action :set_sprint, only: [:show, :edit, :update, :destroy, :archive, :restore]
  before_action :check_permission, except: [:generate_sprint_name]


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

  def archive
    @sprint.is_archived = true
    result = @sprint.save
    error_message =  "#{t(:failure_sprint_archive)} : #{@sprint.errors.messages.to_a.join(' ')}".freeze
    js_callback(result, [t(:success_sprint_archive), error_message], result ? :destroy : nil, {id: @sprint.id})
  end

  def restore
    @sprint.is_archived = false
    result = @sprint.save
    error_message =  "#{t(:failure_sprint_restore)} : #{@sprint.errors.messages.to_a.join(' ')}".freeze
    js_callback(result, [t(:success_sprint_restore), error_message], result ? :destroy : nil, {id: @sprint.id})
  end

  # DELETE /sprints/1
  def destroy
    simple_js_callback(@sprint.destroy, :delete, @sprint, {id: params[:id]})
  end


  def generate_sprint_name
    count = Sprint.where(version_id: params[:value], board_id: @board_decorator.id).pluck('count(id)')
    version = Version.select(:name).find_by_id(params[:value])
    @name = "Sprint #{count.first} : #{version.name}"
    respond_to do |format|
      format.js { respond_to_js }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_sprint
    @sprint = Sprint.find(params[:id] || params[:sprint_id])
  end

  def set_sprints
    @sprints_decorator = Sprint.ordered_sprints(@board.id).decorate(context: {project: @project})
  end


  # Only allow a trusted parameter "white list" through.
  def sprint_params
    params.require(:sprint).permit(:name, :start_date, :end_date, :version_id)
  end
end

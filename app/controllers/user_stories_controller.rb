class UserStoriesController < AgileBoardController
  include Rorganize::RichController::GenericCallbacks
  helper SprintsHelper

  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item('boards') }
  before_filter { |c| c.top_menu_item('projects') }
  before_action :set_user_story, only: [:edit, :update, :destroy]


  def peek_enabled?
    false
  end

  # GET /user_stories
  def index
    @user_stories = UserStory.all
  end

  # GET /user_stories/1
  def show
    @user_story_decorator = UserStory.fetch_dependencies.find(params[:id]).decorate
  end

  # GET /user_stories/new
  def new
    @user_story = UserStory.new(sprint_id: params[:sprint_id]).decorate(context: form_context)
    agile_board_form_callback(agile_board_plugin::user_stories_path(@project.slug), :post)
  end


  # GET /user_stories/1/edit
  def edit
    @user_story = @user_story.decorate(context: form_context)
    agile_board_form_callback(agile_board_plugin::user_story_path(@project.slug, @user_story.id), :put)
  end

  # POST /user_stories
  def create
    @user_story = UserStory.new(user_story_params)
    @user_story.auth
    @user_story.board = @board
    result = @user_story.save
    @sprint = @user_story.get_sprint.decorate(context: {project: @project})
    simple_js_callback(result, :create, @user_story)
  end

  # PATCH/PUT /user_stories/1
  def update
    result = @user_story.update(user_story_params)
    @sprint = @user_story.get_sprint.decorate(context: {project: @project})
    simple_js_callback(result, :update, @user_story)
  end

  # DELETE /user_stories/1
  def destroy
    simple_js_callback(@user_story.destroy, :delete, @user_story, {id: params[:id]})
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user_story
    @user_story = UserStory.find(params[:id])
  end

  def form_context
    {statuses: @board.story_statuses,
     epics: @board.epics,
     categories: @project.categories,
     points: @board.story_points,
     trackers: @project.trackers}
  end

  # Only allow a trusted parameter "white list" through.
  def user_story_params
    params.require(:user_story).permit(:title, :description, :status_id, :point_id, :position, :author_id, :epic_id, :tracker_id, :sprint_id, :project_id, :category_id, :tracker_id)
  end
end

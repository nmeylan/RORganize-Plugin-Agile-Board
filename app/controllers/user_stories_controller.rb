class UserStoriesController < AgileBoardController
  include Rorganize::RichController::GenericCallbacks
  helper SprintsHelper
  before_filter :find_project_with_dependencies, only: [:new_task]
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item('boards') }
  before_filter { |c| c.top_menu_item('projects') }
  before_action :set_user_story, only: [:edit, :update, :destroy, :new_task, :create_task]


  def peek_enabled?
    false
  end

  # GET /user_stories
  def index
    @user_stories = UserStory.all
  end

  # GET /user_stories/1
  def show
    @user_story_decorator = UserStory.fetch_dependencies.includes(issues: [:tracker, :category, :version, :assigned_to, status: :enumeration]).find(params[:id]).decorate(context: {project: @project})
  end

  # GET /user_stories/new
  def new
    @user_story = UserStory.new(sprint_id: params[:sprint_id]).decorate(context: form_context)
    agile_board_form_callback(agile_board_plugin::user_stories_path(@project.slug), :post)
  end


  # GET /user_stories/1/edit
  def edit
    @user_story = @user_story.decorate(context: form_context)
    agile_board_form_callback(agile_board_plugin::user_story_path(@project.slug, @user_story.id, from: params[:from]), :put)
  end

  # POST /user_stories
  def create
    @user_story = UserStory.new(user_story_params)
    @user_story.author = User.current
    @user_story.board = @board
    result = @user_story.save
    @sprint = @user_story.get_sprint(true).decorate(context: {project: @project})
    simple_js_callback(result, :create, @user_story)
  end

  # PATCH/PUT /user_stories/1
  def update
    result = @user_story.update(user_story_params)
    if params[:from]
      @user_story_decorator = @user_story.decorate(context: {project: @project})
    else
      @sprint = @user_story.get_sprint(true).decorate(context: {project: @project})
    end
    simple_js_callback(result, :update, @user_story)
  end

  # DELETE /user_stories/1
  def destroy
    simple_js_callback(@user_story.destroy, :delete, @user_story, {id: params[:id]})
  end

  def new_task
    @issue = Issue.new(category_id: @user_story.category_id,
                       tracker_id: @user_story.tracker_id,
                       version_id: @user_story.tasks_version_id,
                       status_id: @user_story.tasks_status_id,
                       project_id: @project.id
    )
    @members = @project.real_members
    agile_board_form_callback(agile_board_plugin::user_story_create_task_path(@project.slug, @user_story.id), :post, 'new_task')
  end

  def create_task
    @issue = Issue.new(issue_params)
    @issue.author = User.current
    @issue.project = @project
    @user_story.issues << @issue
    if @issue.save && @user_story.save
      respond_to do |format|
        flash[:notice] = t(:successful_creation)
        format.js { js_redirect_to(agile_board_plugin::user_story_path(@project.slug, @user_story.id)) }
      end
    else
      simple_js_callback(false, :create, @issue)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user_story
    @user_story = UserStory.find(params[:id] || params[:user_story_id])
  end

  def form_context
    {statuses: @board.story_statuses,
     epics: @board.epics,
     categories: @project.categories,
     points: @board.story_points,
     trackers: @project.trackers}
  end

  def find_project_with_dependencies
    @project = Project.includes(members: :user).find_by_slug(params[:project_id])
    gon.project_id = @project.slug
  rescue => e
    render_404
  end

  # Only allow a trusted parameter "white list" through.
  def user_story_params
    params.require(:user_story).permit(:title, :description, :status_id, :point_id, :position, :author_id, :epic_id, :tracker_id, :sprint_id, :project_id, :category_id, :tracker_id)
  end

  def issue_params
    params.require(:issue).permit(:category_id, :tracker_id, :version_id, :status_id, :subject, :description, :assigned_to_id)
  end
end

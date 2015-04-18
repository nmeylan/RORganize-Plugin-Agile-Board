require 'shared/history'
class UserStoriesController < AgileBoardController
  include Rorganize::RichController::GenericCallbacks
  include AgileBoard::Controllers::UserStoriesTasksCallback
  helper SprintsHelper
  before_action :find_project_with_dependencies, only: [:new_task]
  before_action {|c| c.add_action_alias={'create_task' => 'new_task'}}
  before_action :check_permission
  before_action { |c| c.menu_context :project_menu }
  before_action { |c| c.menu_item('boards') }
  before_action { |c| c.top_menu_item('projects') }
  before_action :set_user_story, except: [:index, :show, :create, :new]


  def peek_enabled?
    false
  end

  # GET /user_stories
  def index
    @user_stories = UserStory.all
  end

  # GET /user_stories/1
  def show
    @user_story_decorator = decorate_user_story
    journals = Journal.journalizable_activities(@user_story_decorator.id, 'UserStory')
    comments = @user_story_decorator.comments
    respond_to do |format|
      format.html { render 'show', locals: {history: History.new(journals, comments)} }
    end
  end

  # GET /user_stories/new
  def new
    @user_story = UserStory.new(sprint_id: params[:sprint_id]).decorate(context: form_context)
    agile_board_form_callback(agile_board_plugin::user_stories_path(@project.slug), :post)
  end


  # GET /user_stories/1/edit
  def edit
    @user_story = @user_story.decorate(context: form_context)
    agile_board_form_callback(agile_board_plugin::user_story_path(@project.slug, @user_story, from: params[:from]), :put)
  end

  # POST /user_stories
  def create
    @user_story = @board.user_stories.new(user_story_params)
    @user_story.author = User.current
    @user_story.project = @project
    result = @user_story.save
    @user_story = @user_story.decorate(context: {project: @project})
    simple_js_callback(result, :create, @user_story)
  end

  # PATCH/PUT /user_stories/1
  def update
    @user_story.attributes = user_story_params
    result = @user_story.save
    @user_story_decorator = decorate_user_story
    if params[:from]
      locals = {history: History.new(Journal.journalizable_activities(@user_story_decorator.id, 'UserStory'))}
    else
      locals = {}
      @from = :plan
    end
    simple_js_callback(result, :update, @user_story, locals)
  end

  # DELETE /user_stories/1
  def destroy
    result = @user_story.destroy
    if params[:from]
      respond_to do |format|
        flash[:notice] = t(:successful_deletion)
        format.js { js_redirect_to(agile_board_plugin::agile_board_path(@project.slug)) }
      end
    else
      simple_js_callback(result, :delete, @user_story, {id: params[:id], sprint_id: @user_story.sprint_id})
    end
  end

  def change_sprint
    old_sprint = @user_story.sprint_id
    @user_story.sprint = Sprint.find_by_id_and_board_id(params[:sprint_id], @board.id)
    @user_story.change_position(params[:prev_id], params[:next_id])
    result = @user_story.save
    simple_js_callback(result, :update, @user_story, {old_sprint_id: old_sprint,
                                                      sprint_id: @user_story.get_sprint(true).id,
                                                      points: @user_story.points})
  end

  def change_status
    old_status_id = @user_story.status_id
    @user_story.status = StoryStatus.find_by_id_and_board_id(params[:status_id], @board.id)
    simple_js_callback(@user_story.save, :update, @user_story, {old_status_id: old_status_id, new_status_id: @user_story.status_id, story: @user_story})
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user_story
    @user_story = @board.user_stories.find_by_sequence_id!(params[:id] || params[:user_story_id])
  end

  def decorate_user_story
    @board.user_stories.fetch_dependencies.fetch_issues_dependencies.find_by_sequence_id!(params[:id] || params[:user_story_id]).decorate(context: {project: @project})
  end

  def form_context
    {statuses: @board.story_statuses,
     epics: @board.epics,
     categories: @project.categories,
     points: @board.story_points,
     trackers: @project.trackers}
  end

  def show_redirection(message)
    respond_to do |format|
      flash[:notice] = message
      format.html {redirect_to agile_board_plugin::user_story_path(@project.slug, @user_story)}
      format.js { js_redirect_to(agile_board_plugin::user_story_path(@project.slug, @user_story)) }
    end
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

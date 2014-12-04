require 'shared/history'
class UserStoriesController < AgileBoardController
  include Rorganize::RichController::GenericCallbacks
  helper SprintsHelper
  before_filter :find_project_with_dependencies, only: [:new_task]
  before_filter {|c| c.add_action_alias={'create_task' => 'new_task'}}
  before_action :check_permission
  before_filter { |c| c.menu_context :project_menu }
  before_filter { |c| c.menu_item('boards') }
  before_filter { |c| c.top_menu_item('projects') }
  before_action :set_user_story, only: [:edit, :update, :destroy, :new_task, :create_task, :detach_tasks, :change_sprint, :change_status]


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
    agile_board_form_callback(agile_board_plugin::user_story_path(@project.slug, @user_story.id, from: params[:from]), :put)
  end

  # POST /user_stories
  def create
    @user_story = UserStory.new(user_story_params)
    @user_story.author = User.current
    @user_story.board = @board
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
        format.js { js_redirect_to(agile_board_plugin::agile_board_index_path(@project.slug)) }
      end
    else
      simple_js_callback(result, :delete, @user_story, {id: params[:id], sprint_id: @user_story.sprint_id})
    end
  end

  # GET /user_stories/:user_story_id/new_task
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

  # POST /user_stories/:user_story_id/create_task
  def create_task
    @issue = Issue.new(issue_params)
    @issue.author = User.current
    @issue.project = @project
    @user_story.issues << @issue
    if @issue.save && @user_story.save
      show_redirection(t(:successful_creation))
    else
      simple_js_callback(false, :create, @issue)
    end
  end

  # POST /user_stories/:user_story_id/detach_tasks
  def detach_tasks
    @user_story.detach_tasks(params[:ids])
    show_redirection(t(:successful_update))
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
    @user_story = UserStory.find(params[:id] || params[:user_story_id])
  end

  def decorate_user_story
    UserStory.fetch_dependencies.fetch_issues_dependencies.find(params[:id] || params[:user_story_id]).decorate(context: {project: @project})
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
      format.js { js_redirect_to(agile_board_plugin::user_story_path(@project.slug, @user_story.id)) }
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

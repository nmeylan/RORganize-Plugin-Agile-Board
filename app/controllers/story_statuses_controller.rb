class StoryStatusesController < ApplicationController
  include Rorganize::RichController
  before_action :set_story_status, only: [:show, :edit, :update, :destroy]

  # GET /story_statuses
  def index
    @story_statuses = StoryStatus.all
  end

  # GET /story_statuses/new
  def new
    @story_status = StoryStatus.new(color: '#6cc644')
    respond_to do |format|
      format.js { respond_to_js locals: {new: true} }
    end
  end

  # GET /story_statuses/1/edit
  def edit
    respond_to do |format|
      format.js { respond_to_js locals: {edit: true} }
    end
  end

  # POST /story_statuses
  def create
    @story_status = StoryStatus.new(story_status_params).decorate
    @story_status.board = Board.find_by_project_id(@project.id)
    js_callback(@story_status.save, [t(:successful_creation), "#{t(:failure_creation)} : #{@story_status.errors.full_messages.join(', ')}"], 'new', {new: false})
  end

  # PATCH/PUT /story_statuses/1
  def update
    simple_js_callback(@story_status.update(story_status_params), :update)
  end

  def change_position
    StoryStatus.update_positions(@project.id, params[:ids])
    respond_to do |format|
      format.js { respond_to_js action: 'do_nothing', response_header: :success, response_content: t(:successful_update) }
    end
  end

  # DELETE /story_statuses/1
  def destroy
    @story_status.destroy
    respond_to do |format|
      format.js { respond_to_js action: 'destroy', locals: {id: params[:id]}, response_header: :success, response_content: t(:successful_deletion) }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_story_status
    @story_status = StoryStatus.find(params[:id])
    @story_status = @story_status.decorate if @story_status
  end

  # Only allow a trusted parameter "white list" through.
  def story_status_params
    params.require(:story_status).permit(:name, :color)
  end
end

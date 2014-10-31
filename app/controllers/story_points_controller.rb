class StoryPointsController < ApplicationController
  before_action :set_story_status, only: [:edit, :update]
  before_action :check_permission

  # GET /story_statuses/1/edit
  def edit
    @point = StoryPoint.find(params[:id])
    respond_to do |format|
      format.js { respond_to_js action: 'edit_point', locals: {point: @point, edition: true} }
    end
  end

  # PATCH/PUT /story_statuses/1
  def update
    if params[:point].blank?
      @point.destroy
      response_content = t(:successful_deletion)
    else
      @point.value = params[:point]
      @point.save
      response_content = t(:successful_update)
    end
    response_header = :success
    respond_to do |format|
      format.js { respond_to_js action: 'add_points', locals: {addition: false}, response_content: response_content, response_header: response_header }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_story_status
    @point = StoryPoint.find(params[:id])
    @board_decorator = @point.board.decorate(context: {project: @project})
    @board_decorator.context.merge!({points: StoryPoint.where(board_id: @board_decorator.id).decorate})
  end

end
